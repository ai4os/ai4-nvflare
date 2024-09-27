job "{###JOB_UUID###}" {
  datacenters = ["ifca-ai4eosc"]
  namespace = "ai4eosc"
  type = "service"
   
  meta {
    job_uuid                            = "{###JOB_UUID###}"
    hostname                            = "ifca-deployments.cloud.ai4eosc.eu"
    force_pull_images                   = false
     
    #
    # rclone
    RCLONE_CONFIG                       = "/srv/.rclone/rclone.conf"
    RCLONE_CONFIG_RSHARE_TYPE           = "webdav"
    RCLONE_CONFIG_RSHARE_URL            = "https://share.services.ai4os.eu/remote.php/dav/files/{###NVFLARE_NEXTCLOUD_USER###}"
    RCLONE_CONFIG_RSHARE_VENDOR         = "nextcloud"
    RCLONE_CONFIG_RSHARE_USER           = "{###NVFLARE_NEXTCLOUD_USER###}"
    RCLONE_CONFIG_RSHARE_PASS           = "{###NVFLARE_NEXTCLOUD_PASSWORD###}"
     
    #
    # dashboard
    #
    image_dashboard                     = "registry.services.ai4os.eu/ai4os/ai4-nvflare-dashboard"
    dashboard_credentials               = "admin:{###NVFLARE_DASHBOARD_PASSWORD###}"
     
    #
    # server
    #
    image_server                        = "registry.services.ai4os.eu/ai4os/ai4-nvflare-server"
  }
 
  group "fl" {
 
    # Only launch in compute nodes (to avoid clashing with system jobs, eg. Traefik)
    constraint {
        attribute = "${meta.compute}"
        operator  = "="
        value     = "true"
    }

    # Avoid rescheduling the job on **other** nodes during a network cut
    # Command not working due to https://github.com/hashicorp/nomad/issues/16515
    reschedule {
      attempts  = 0
      unlimited = false
    }

    restart {
      attempts = 3
      interval = "5m"
      delay = "30s"
      mode = "delay"
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
        "traefik.http.routers.${NOMAD_META_job_uuid}-dashboard.tls=true",
        "traefik.http.routers.${NOMAD_META_job_uuid}-dashboard.entrypoints=websecure",
        "traefik.http.routers.${NOMAD_META_job_uuid}-dashboard.rule=Host(`${NOMAD_META_job_uuid}-dashboard.${NOMAD_META_hostname}`)",
      ]
    }
 
    service {
      name = "${BASE}-dashboard-api"
      port = "dashboard-api"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_META_job_uuid}-dashboard-api.tls=true",
        "traefik.http.routers.${NOMAD_META_job_uuid}-dashboard-api.entrypoints=websecure",
        "traefik.http.routers.${NOMAD_META_job_uuid}-dashboard-api.rule=Host(`${NOMAD_META_job_uuid}-dashboard-api.${NOMAD_META_hostname}`)",
      ]
    }
 
    service {
      name = "${BASE}-server-fl"
      port = "server-fl"
      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.${NOMAD_META_job_uuid}-server-fl.tls=true",
        "traefik.tcp.routers.${NOMAD_META_job_uuid}-server-fl.tls.passthrough=true",
        "traefik.tcp.routers.${NOMAD_META_job_uuid}-server-fl.entrypoints=nvflare_fl",
        "traefik.tcp.routers.${NOMAD_META_job_uuid}-server-fl.rule=HostSNI(`${NOMAD_META_job_uuid}-server.${NOMAD_META_hostname}`)",
      ]
    }
 
    service {
      name = "${BASE}-server-admin"
      port = "server-admin"
      tags = [
        "traefik.enable=true",
        "traefik.tcp.routers.${NOMAD_META_job_uuid}-server-admin.tls=true",
        "traefik.tcp.routers.${NOMAD_META_job_uuid}-server-admin.tls.passthrough=true",
        "traefik.tcp.routers.${NOMAD_META_job_uuid}-server-admin.entrypoints=nvflare_admin",
        "traefik.tcp.routers.${NOMAD_META_job_uuid}-server-admin.rule=HostSNI(`${NOMAD_META_job_uuid}-server.${NOMAD_META_hostname}`)",
      ]
    }
 
    service {
      name = "${BASE}-server-jupyter"
      port = "server-jupyter"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_META_job_uuid}-server-jupyter.tls=true",
        "traefik.http.routers.${NOMAD_META_job_uuid}-server-jupyter.entrypoints=websecure",
        "traefik.http.routers.${NOMAD_META_job_uuid}-server-jupyter.rule=Host(`${NOMAD_META_job_uuid}-server.${NOMAD_META_hostname}`)",
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
        REMOTE_PATH                 = "rshare:/nvflare-instances/${NOMAD_META_job_uuid}.${NOMAD_META_hostname}"
        LOCAL_PATH                  = "/storage"
      }
      config {
        image   = "registry.services.ai4os.eu/ai4os/docker-storage:latest"
        privileged = true
        volumes = [
          "/nomad-storage/${NOMAD_META_job_uuid}.${NOMAD_META_hostname}:/storage:shared",
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
        pass = ${NOMAD_META_RCLONE_CONFIG_RSHARE_PASS}
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
          "sudo umount /nomad-storage/${NOMAD_META_job_uuid}.${NOMAD_META_hostname} && sudo rmdir /nomad-storage/${NOMAD_META_job_uuid}.${NOMAD_META_hostname}"
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
          "/nomad-storage/${NOMAD_META_job_uuid}.${NOMAD_META_hostname}/dashboard:/var/tmp/nvflare/dashboard:shared",
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
          "/nomad-storage/${NOMAD_META_job_uuid}.${NOMAD_META_hostname}/server/tf:/tf:shared",
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
     
  }
}

