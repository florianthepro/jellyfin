#===== setup =====
docker compose -f /home/$username/docker/compose.yaml up -d

#tailscale funnel 8096 on
#===== end =====
clear
cat ./docker/compose.yaml
ask "done? "
