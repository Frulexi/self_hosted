terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

# Define  Docker image resources
resource "docker_image" "flame" {
  name         = "pawelmalak/flame:latest"
  keep_locally = false
}

resource "docker_image" "nginx_proxy" {
  name = "jc21/nginx-proxy-manager:latest"
  keep_locally = false
}

resource "docker_image" "nextcloud" {
  name = "nextcloud"
  keep_locally = false
}

resource "docker_image" "mariadb" {
  name = "mariadb:10.6"
  keep_locally = false
}

resource "docker_image" "portainer" {
  name = "portainer/portainer-ce:latest"
  keep_locally = false
}


# Define Docker volumes
resource "docker_volume" "nextcloud_volume" {
  name = "nextcloud"
}

resource "docker_volume" "mariadb_volume" {
  name = "mariadb"
}

resource "docker_volume" "portainer_data" {
  name = "portainer_data"
}

resource "docker_network" "nextcloud" {
  name = "nextcloud"
}

# Define Docker container resource
resource "docker_container" "nginx" {
  image = docker_image.nginx_proxy.image_id
  name = "nginx_proxy"

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 81
    external = 81
  }

  ports {
    internal = 443
    external = 443 
  }

  volumes {
    host_path = "${var.host_path}/nginx_proxy/data"
    container_path = "/data"
  }

  volumes {
    host_path = "${var.host_path}/nginx_proxy/letsencrypt"
    container_path = "/etc/letsencrypt"
  }

  restart = "unless-stopped"

  network_mode = "bridge"
}

resource "docker_container" "flame" {
  image          = docker_image.flame.image_id
  name           = "flame"
  
  volumes {
    host_path      = "${var.host_path}/flame/data"
    container_path = "/app/data"
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  ports {
    internal = 5005
    external = 5005
  }

  env = [
    "PASSWORD=${var.admin_password}"
  ]

  restart = "unless-stopped"

  network_mode = "bridge"
}

resource "docker_container" "mariadb" {
  image = docker_image.mariadb.image_id
  name  = "nextcloud_db"
  
  env = [
    "MYSQL_ROOT_PASSWORD=${var.root_password}", # Replace with a strong root password
    "MYSQL_PASSWORD=${var.admin_password}",      # Replace with the user password
    "MYSQL_DATABASE=nextcloud",
    "MYSQL_USER=${var.admin_user}"
  ]
  
  # Command options
  command = [
    "--transaction-isolation=READ-COMMITTED",
    "--log-bin=binlog",
    "--binlog-format=ROW"
  ]
  
  # Volume attachment
  volumes {
    volume_name    = docker_volume.mariadb_volume.name
    container_path = "/var/lib/mysql"
  }

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.nextcloud.name
  }
}

resource "docker_container" "nextcloud" {
  image = docker_image.nextcloud.image_id
  name  = "nextcloud"


  # Port mapping
  ports {
    internal = 80
    external = 5080
  }

  # Environment variables
  env = [
    "MYSQL_PASSWORD=${var.admin_password}",       # Must match the password set for the db service
    "MYSQL_DATABASE=nextcloud",
    "MYSQL_USER=${var.admin_user}",
    "MYSQL_HOST=${docker_container.mariadb.name}"
  ]

  # Volume attachment
  volumes {
    volume_name    = docker_volume.nextcloud_volume.name
    container_path = "/var/www/html"
  }
  
  # Link to the db container
  depends_on = [
    docker_container.mariadb
  ]

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.nextcloud.name
  }
}

resource "docker_container" "portainer" {
  image = docker_image.portainer.image_id
  name = "portainer"

  volumes {
    volume_name = docker_volume.portainer_data.name
    container_path = "/data"
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }

  ports {
    external = 801
    internal = 800
  }

  ports {
    external = 9443
    internal = 9443
  }
}
