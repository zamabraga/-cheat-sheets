variable "postgres_user" {
  type= string
  default= "zabbix"
}

variable "postgres_password" {
  type= string
  default= "zabbix"
}

variable "postgres_db" {
  type= string
  default= "zabbix"
}

variable "datacenters" {
  type= list(string)
  default=["dc1"]
} 


job "zabbix" {
  datacenters = var.datacenters

  group "zabbix" {
   
    network {
       port "db" {
         static = 5432
       }    

       port "zbx_server" {
         static = 10051
       }    

       port "zbx_web_1" {
         static = 8080
       }  

       port "zbx_web_2" {
         static = 8443
       }       
    }

     task "database" {
      driver = "docker"
      
      env {
          POSTGRES_USER= var.postgres_user
          POSTGRES_PASSWORD=var.postgres_password
          POSTGRES_DB=var.postgres_db
      }
     
      config {
        image = "postgres:15-bullseye"      
        ports = ["db"]
        
      }     
      
      resources {
        cpu    = 5
        memory = 512
      }
    }

     task "server" {
      driver = "docker"
      
      env {
          DB_SERVER_HOST="${NOMAD_IP_db}"
          DB_SERVER_PORT="${NOMAD_PORT_db}"
          POSTGRES_USER= var.postgres_user
          POSTGRES_PASSWORD=var.postgres_password
          POSTGRES_DB=var.postgres_db

          ZBX_LISTENPORT="${NOMAD_PORT_zbx_server}"
      }
     
      config {
        image = "zabbix/zabbix-server-pgsql:ubuntu-6.4-latest"      
        ports = ["zbx_server"]
        
      }     
      
      resources {
        cpu    = 5
        memory = 512
      }
    }

    task "web" {
      driver = "docker"
      
      env {
          ZBX_SERVER_HOST="${NOMAD_IP_zbx_server}"
          ZBX_SERVER_PORT="${NOMAD_PORT_zbx_server}"
          
          DB_SERVER_HOST="${NOMAD_IP_db}"
          DB_SERVER_PORT="${NOMAD_PORT_db}"
          POSTGRES_USER= var.postgres_user
          POSTGRES_PASSWORD=var.postgres_password
          POSTGRES_DB=var.postgres_db

      }
     
      config {
        image = "zabbix/zabbix-web-nginx-pgsql:ubuntu-6.4-latest"      
        ports = ["zbx_web_1", "zbx_web_2"]
        
      }     
      
      resources {
        cpu    = 5
        memory = 250
      }
    }
  }
}
