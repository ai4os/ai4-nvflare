job "ai4-nvflare-01" {
  datacenters = ["iisas-ai4eosc"]
  namespace = "ai4eosc"
  type = "service"
   
  meta {
    instance_id                         = "ai4-nvflare-01"
    hostname                            = "iisas-deployments.cloud.ai4eosc.eu"
    force_pull_images                   = true
     
    #
    # rclone
    RCLONE_CONFIG                       = "/srv/.rclone/rclone.conf"
    RCLONE_CONFIG_RSHARE_TYPE           = "webdav"
    RCLONE_CONFIG_RSHARE_URL            = "https://share.services.ai4os.eu/remote.php/dav/files/EGI_Checkin-********"
    RCLONE_CONFIG_RSHARE_VENDOR         = "nextcloud"
    RCLONE_CONFIG_RSHARE_USER           = "********"
    RCLONE_CONFIG_RSHARE_PASS           = "********"
    RCLONE_CONFIG_RSHARE_PASS_OBSCURED  = "********"
     
    #
    # dashboard
    #
    image_dashboard                     = "sht3v0/ai4-nvflare-dashboard:2.5.0"
    dashboard_credentials               = "admin:********"
     
    #
    # server
    #
    image_server                        = "sht3v0/ai4-nvflare-server:2.5.0"
     
    #
    # client
    #
    image_client                        = "sht3v0/ai4-nvflare-client:2.5.0"
    wandb_api_key                       = "********"
    wandb_mode                          = "online"
    wandb__service_wait                 = "120"
  }
 
  group "fl" {
 
    # Only launch in compute nodes (to avoid clashing with system jobs, eg. Traefik)
    constraint {
        attribute = "${meta.compute}"
        operator  = "="
        value     = "true"
    }
     
    network {
      port "dashboard-api" {
        to = 8443
      }
      port "dashboard" {
        to = 80
      }
      port "server-fl" {
        to = 8002
      }
      port "server-admin" {
        to = 8003
      }
      port "server-jupyter" {
        to = 8888
      }
      port "client1-jupyter" {
        to = 8888
      }
      port "client2-jupyter" {
        to = 8888
      }
      port "client3-jupyter" {
        to = 8888
      }
    }
     
    service {
      name = "${BASE}-dashboard"
      port = "dashboard"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_META_instance_id}-dashboard.tls=true",
        "traefik.http.routers.${NOMAD_META_instance_id}-dashboard.entrypoints=websecure",
        "traefik.http.routers.${NOMAD_META_instance_id}-dashboard.rule=Host(`${NOMAD_META_instance_id}-dashboard.${NOMAD_META_hostname}`)",
      ]
    }
 
    service {
      name = "${BASE}-dashboard-api"
      port = "dashboard-api"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_META_instance_id}-dashboard-api.tls=true",
        "traefik.http.routers.${NOMAD_META_instance_id}-dashboard-api.entrypoints=websecure",
        "traefik.http.routers.${NOMAD_META_instance_id}-dashboard-api.rule=Host(`${NOMAD_META_instance_id}-dashboard-api.${NOMAD_META_hostname}`)",
      ]
    }
 
    service {
      name = "${BASE}-server-fl"
      port = "server-fl"
      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.${NOMAD_META_instance_id}-server-fl.tls=true",
        "traefik.tcp.routers.${NOMAD_META_instance_id}-server-fl.tls.passthrough=true",
        "traefik.tcp.routers.${NOMAD_META_instance_id}-server-fl.entrypoints=nvflare_fl",
        "traefik.tcp.routers.${NOMAD_META_instance_id}-server-fl.rule=HostSNI(`${NOMAD_META_instance_id}-server.${NOMAD_META_hostname}`)",
      ]
    }
 
    service {
      name = "${BASE}-server-admin"
      port = "server-admin"
      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.${NOMAD_META_instance_id}-server-admin.tls=true",
        "traefik.tcp.routers.${NOMAD_META_instance_id}-server-admin.tls.passthrough=true",
        "traefik.tcp.routers.${NOMAD_META_instance_id}-server-admin.entrypoints=nvflare_admin",
        "traefik.tcp.routers.${NOMAD_META_instance_id}-server-admin.rule=HostSNI(`${NOMAD_META_instance_id}-server.${NOMAD_META_hostname}`)",
      ]
    }
 
    service {
      name = "${BASE}-server-jupyter"
      port = "server-jupyter"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_META_instance_id}-server-jupyter.tls=true",
        "traefik.http.routers.${NOMAD_META_instance_id}-server-jupyter.entrypoints=websecure",
        "traefik.http.routers.${NOMAD_META_instance_id}-server-jupyter.rule=Host(`${NOMAD_META_instance_id}-server.${NOMAD_META_hostname}`)",
      ]
    }
 
    service {
      name = "${BASE}-client1-jupyter"
      port = "client1-jupyter"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_META_instance_id}-client1-jupyter.tls=true",
        "traefik.http.routers.${NOMAD_META_instance_id}-client1-jupyter.entrypoints=websecure",
        "traefik.http.routers.${NOMAD_META_instance_id}-client1-jupyter.rule=Host(`${NOMAD_META_instance_id}-client1.${NOMAD_META_hostname}`)",
      ]
    }
 
    service {
      name = "${BASE}-client2-jupyter"
      port = "client2-jupyter"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_META_instance_id}-client2-jupyter.tls=true",
        "traefik.http.routers.${NOMAD_META_instance_id}-client2-jupyter.entrypoints=websecure",
        "traefik.http.routers.${NOMAD_META_instance_id}-client2-jupyter.rule=Host(`${NOMAD_META_instance_id}-client2.${NOMAD_META_hostname}`)",
      ]
    }
 
    service {
      name = "${BASE}-client3-jupyter"
      port = "client3-jupyter"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_META_instance_id}-client3-jupyter.tls=true",
        "traefik.http.routers.${NOMAD_META_instance_id}-client3-jupyter.entrypoints=websecure",
        "traefik.http.routers.${NOMAD_META_instance_id}-client3-jupyter.rule=Host(`${NOMAD_META_instance_id}-client3.${NOMAD_META_hostname}`)",
      ]
    }
 
    task "storagetask" {
      lifecycle {
        hook = "prestart"
        sidecar = "true"
      }
      driver = "docker"
      env {
        RCLONE_CONFIG               = "${NOMAD_META_RCLONE_CONFIG}"
        RCLONE_CONFIG_RSHARE_TYPE   = "webdav"
        RCLONE_CONFIG_RSHARE_URL    = "${NOMAD_META_RCLONE_CONFIG_RSHARE_URL}"
        RCLONE_CONFIG_RSHARE_VENDOR = "${NOMAD_META_RCLONE_CONFIG_RSHARE_VENDOR}"
        RCLONE_CONFIG_RSHARE_USER   = "${NOMAD_META_RCLONE_CONFIG_RSHARE_USER}"
        RCLONE_CONFIG_RSHARE_PASS   = "${NOMAD_META_RCLONE_CONFIG_RSHARE_PASS}"
        REMOTE_PATH                 = "rshare:/nvflare-instances/${NOMAD_META_instance_id}.${NOMAD_META_hostname}"
        LOCAL_PATH                  = "/storage"
      }
      config {
        image   = "ignacioheredia/ai4-docker-storage"
        privileged = true
        volumes = [
          "/nomad-storage/${NOMAD_META_instance_id}.${NOMAD_META_hostname}:/storage:shared",
        ]
        mount {
          type = "bind"
          target = "/srv/.rclone/rclone.conf"
          source = "local/rclone.conf"
          readonly = false
        }
        mount {
          type = "bind"
          target = "/mount_storage.sh"
          source = "local/mount_storage.sh"
          readonly = false
        }
      }
      template {
        data = <<-EOF
        [ai4eosc-share]
        type = webdav
        url = https://share.services.ai4os.eu/remote.php/dav
        vendor = nextcloud
        user = ${NOMAD_META_RCLONE_CONFIG_RSHARE_USER}
        pass = ${NOMAD_META_RCLONE_CONFIG_RSHARE_PASS_OBSCURED}
        EOF
        destination = "local/rclone.conf"
      }
      template {
        data = <<-EOF
        export RCLONE_CONFIG_RSHARE_PASS=$(rclone obscure $RCLONE_CONFIG_RSHARE_PASS)
        rclone mount $REMOTE_PATH $LOCAL_PATH --allow-non-empty --allow-other --vfs-cache-mode full
        EOF
        destination = "local/mount_storage.sh"
      }
      resources {
        cpu    = 50        # minimum number of CPU MHz is 2
        memory = 2000
      }
    }
     
    task "storagecleanup" {
      lifecycle {
        hook = "poststop"
      }
      driver = "raw_exec"
      config {
        command = "/bin/bash"
        args = [
          "-c",
          "sudo umount /nomad-storage/${NOMAD_META_instance_id}.${NOMAD_META_hostname} && sudo rmdir /nomad-storage/${NOMAD_META_instance_id}.${NOMAD_META_hostname}"
        ]
      }
    }
     
    task "dashboard" {
      driver = "docker"
      env {
        NVFL_CREDENTIAL = "${NOMAD_META_dashboard_credentials}"
        VARIABLE_NAME = "app"
      }
      config {
        image = "${NOMAD_META_image_dashboard}"
        force_pull = "${NOMAD_META_force_pull_images}"
        ports = ["dashboard", "dashboard-api"]
        volumes = [
          "/nomad-storage/${NOMAD_META_instance_id}.${NOMAD_META_hostname}/dashboard:/var/tmp/nvflare/dashboard:shared",
        ]
      }
    }
 
    task "server" {
      driver = "docker"
      config {
        image = "${NOMAD_META_image_server}"
        force_pull = "${NOMAD_META_force_pull_images}"
        ports = ["server-fl", "server-admin", "server-jupyter"]
        volumes = [
          "/nomad-storage/${NOMAD_META_instance_id}.${NOMAD_META_hostname}/server/tf:/tf:shared",
        ]
        command = "jupyter-lab"
        args = [
          # passwd: server
          # how to generate password: python3 -c "from jupyter_server.auth import passwd; print(passwd('server'))"
          "--ServerApp.password='argon2:$argon2id$v=19$m=10240,t=10,p=8$McTfyrWczp//e04uGym7IA$7XutdTbd43ROwODLwLJbUMwfj7BdQvzlpnQygKxT0JU'",
                    "--port=8888",
          "--ip=0.0.0.0",
          "--notebook-dir=/tf",
          "--no-browser",
          "--allow-root"
        ]
      }
    }
     
    task "client1" {
      driver = "docker"
      config {
        image = "${NOMAD_META_image_client}"
        force_pull = "${NOMAD_META_force_pull_images}"
        ports = ["client1-jupyter"]
        volumes = [
          "/nomad-storage/${NOMAD_META_instance_id}.${NOMAD_META_hostname}/client1/tf:/tf:shared",
        ]
        command = "jupyter-lab"
        args = [
          # passwd: client1
          # how to generate password: python3 -c "from jupyter_server.auth import passwd; print(passwd('client1'))"
          "--ServerApp.password='argon2:$argon2id$v=19$m=10240,t=10,p=8$DIQzNsiAAPXvmbGWIQokPw$9KNlyJ98P+mLTl3mhsBickmG9UjV0v8EEweCbeHVUzY'",
                    "--port=8888",
          "--ip=0.0.0.0",
          "--notebook-dir=/tf",
          "--no-browser",
          "--allow-root"
        ]
      }
    }
     
    task "client2" {
      driver = "docker"
      config {
        image = "${NOMAD_META_image_client}"
        force_pull = "${NOMAD_META_force_pull_images}"
        ports = ["client2-jupyter"]
        volumes = [
          "/nomad-storage/${NOMAD_META_instance_id}.${NOMAD_META_hostname}/client2/tf:/tf:shared",
        ]
        command = "jupyter-lab"
        args = [
          # passwd: client2
          # how to generate password: python3 -c "from jupyter_server.auth import passwd; print(passwd('client2'))"
          "--ServerApp.password='argon2:$argon2id$v=19$m=10240,t=10,p=8$xJDANghO2/hvbaPKDzHjgg$H1T/0OthiKbrWKxSjYk0IJHLVNUVc1CmHCbU7FgDDuk'",
                    "--port=8888",
          "--ip=0.0.0.0",
          "--notebook-dir=/tf",
          "--no-browser",
          "--allow-root"
        ]
      }
    }
     
    task "client3" {
      driver = "docker"
      config {
        image = "${NOMAD_META_image_client}"
        force_pull = "${NOMAD_META_force_pull_images}"
        ports = ["client3-jupyter"]
        volumes = [
          "/nomad-storage/${NOMAD_META_instance_id}.${NOMAD_META_hostname}/client3/tf:/tf:shared",
        ]
        command = "jupyter-lab"
        args = [
          # passwd: client3
          # how to generate password: python3 -c "from jupyter_server.auth import passwd; print(passwd('client3'))"
          "--ServerApp.password='argon2:$argon2id$v=19$m=10240,t=10,p=8$Tre103/pUpaq2zfSpiSaGQ$S8oagCHJrQ+FmrjzHPcyopK2rJHplDJpifDTaw0Z3LE'",
                    "--port=8888",
          "--ip=0.0.0.0",
          "--notebook-dir=/tf",
          "--no-browser",
          "--allow-root"
        ]
      }
    }
 
  }
}

