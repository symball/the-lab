## playbook: super.yml

```

  play #1 (all): all    TAGS: [always]
    tasks:
      Create control directory  TAGS: [always]

  play #2 (all): all    TAGS: [always]
    tasks:
      Create local reference for device TAGS: [always]

  play #3 (all): all    TAGS: [maintenance]
    tasks:
      common : Install common app loadout       TAGS: [maintenance]
      common : Set Hostname     TAGS: [maintenance]
      common : Setup common user        TAGS: [maintenance]
      common : Update system packages   TAGS: [maintenance]
      common : Install Docker   TAGS: [maintenance]

  play #4 (nginx_facade): nginx_facade  TAGS: [nginx_facade]
    tasks:
      nginx_facade : Install Nginx      TAGS: [nginx_facade]
      nginx_facade : Make sure working directories are present  TAGS: [nginx_facade]
      nginx_facade : Record Job number  TAGS: [nginx_facade]
      nginx_facade : Copy across the fallback site      TAGS: [nginx_facade]
      nginx_facade : Check Diffie Helmann has been generated    TAGS: [nginx_facade]
      nginx_facade : Generate the Diffie Helmann. This may take a while, using {{ nginx_facade_diffie_hellman_bytes }} bytes    TAGS: [nginx_facade]
      nginx_facade : Copy over generic nginx configuration      TAGS: [nginx_facade]
      nginx_facade : Enable the Nginx service   TAGS: [nginx_facade]
      nginx_facade : Render the sudoers file allowing common user restart capability    TAGS: [nginx_facade]

  play #5 (elasticsearch): elasticsearch        TAGS: [elasticsearch]
    tasks:
      elasticsearch : Add Elasticsearch apt key TAGS: [elasticsearch]
      elasticsearch : Adding Elasticsearch repo TAGS: [elasticsearch]
      elasticsearch : Install packages  TAGS: [elasticsearch]
      elasticsearch : Create config     TAGS: [elasticsearch]
      elasticsearch : Starting Elasticsearch    TAGS: [elasticsearch]
      elasticsearch : Render the sudoers file allowing common user restart capability   TAGS: [elasticsearch]

  play #6 (kibana): kibana      TAGS: [kibana]
    tasks:
      kibana : Add Elasticsearch apt key        TAGS: [kibana]
      kibana : Adding Elasticsearch repo        TAGS: [kibana]
      kibana : Install Kibana   TAGS: [kibana]
      set_fact  TAGS: [kibana]
      kibana : Create configuration     TAGS: [kibana]
      kibana : Start Kibana     TAGS: [kibana]
      kibana : Render the sudoers file allowing common user restart capability  TAGS: [kibana]
      kibana : Generate Nginx password rule     TAGS: [kibana]
      kibana : Put the password rule in place   TAGS: [kibana]
      kibana : Check switch to see if key setup for {{ domain }}      TAGS: [kibana]
      kibana : Generate self signed security certificate        TAGS: [kibana]
      kibana : Generate letsencrypt certificate TAGS: [kibana]
      kibana : Copy across the Nginx rule       TAGS: [kibana]
      kibana : Restart Nginx to pickup the rule TAGS: [kibana]

  play #7 (metricbeat): metricbeat      TAGS: [metricbeat]
    tasks:
      metricbeat : Add Elasticsearch apt key    TAGS: [metricbeat]
      metricbeat : Adding Elasticsearch repo    TAGS: [metricbeat]
      metricbeat : Install MetricBeat   TAGS: [metricbeat]
      set_fact  TAGS: [metricbeat]
      metricbeat : Create configuration TAGS: [metricbeat]
      metricbeat : Render the sudoers file allowing common user restart capability      TAGS: [metricbeat]
      metricbeat : Start MetricBeat     TAGS: [metricbeat]

  play #8 (mailhog): mailhog    TAGS: [mailhog]
    tasks:
      Install mailhog   TAGS: [mailhog]
      Render the sudoers file allowing common user restart capability   TAGS: [mailhog]
      Generate Nginx password rule      TAGS: [mailhog]
      Put the password rule in place    TAGS: [mailhog]
      Check switch to see if key setup for {{ domain }}       TAGS: [mailhog]
      Generate self signed security certificate TAGS: [mailhog]
      Generate letsencrypt certificate  TAGS: [mailhog]
      Copy across the Nginx rule        TAGS: [mailhog]
      Restart Nginx to pickup the rule  TAGS: [mailhog]

  play #9 (nodejs): nodejs      TAGS: [nodejs]
    tasks:
      nodejs : Add GPG key for Node from {{ node_repository_key_path }} TAGS: [nodejs]
      nodejs : add repo for NodeJS {{ node_version }}   TAGS: [nodejs]
      nodejs : install nodejs   TAGS: [nodejs]

  play #10 (postgresql): postgresql     TAGS: [postgresql]
    tasks:
      postgresql : Record Job number    TAGS: [postgresql]
      postgresql : Install base packages        TAGS: [postgresql]
      postgresql : Start postgresql service     TAGS: [postgresql]
      postgresql : Render the sudoers file allowing common user restart capability      TAGS: [postgresql]
      postgresql : Render configuration files   TAGS: [postgresql]
      postgresql : Restart PostgreSQL service   TAGS: [postgresql]

  play #11 (redis): redis       TAGS: [redis]
    tasks:
      redis : Prepare Redis specific working paths      TAGS: [redis]
      redis : Install Redis Server      TAGS: [redis]
      redis : Record Job number TAGS: [redis]
      redis : Render the sudoers file allowing common user restart capability   TAGS: [redis]
      redis : Render the Redis Server configuration     TAGS: [redis]
      redis : Enable the SystemD service        TAGS: [redis]

  play #12 (pledgecamp_backend): pledgecamp_backend     TAGS: [pledgecamp_backend]
    tasks:
      Install uwsgi     TAGS: [pledgecamp_backend]
      Install python support services   TAGS: [pledgecamp_backend]
      Render the sudoers file allowing common user restart capability   TAGS: [pledgecamp_backend]

  play #13 (pledgecamp_frontend): pledgecamp_frontend   TAGS: [pledgecamp_frontend]
    tasks:
      Check switch to see if key setup for {{ domain }}       TAGS: [pledgecamp_frontend]
      Generate self signed security certificate TAGS: [pledgecamp_frontend]
      Generate letsencrypt certificate  TAGS: [pledgecamp_frontend]

  play #14 (pledgecamp_tokenbridge_backend): pledgecamp_tokenbridge_backend     TAGS: [pledgecamp_tokenbridge_backend]
    tasks:
      Render initial Nginx configuration file for letsencrypt checking  TAGS: [pledgecamp_tokenbridge_backend]
      Test the Nginx configuration      TAGS: [pledgecamp_tokenbridge_backend]
      Restart nginx for acme challenge pickup   TAGS: [pledgecamp_tokenbridge_backend]
      Check switch to see if key setup for {{ domain }}       TAGS: [pledgecamp_tokenbridge_backend]
      Generate self signed security certificate TAGS: [pledgecamp_tokenbridge_backend]
      Generate letsencrypt certificate  TAGS: [pledgecamp_tokenbridge_backend]
      Remove the temporary configuration file   TAGS: [pledgecamp_tokenbridge_backend]
      Symlink the certificate file in to place  TAGS: [pledgecamp_tokenbridge_backend]
      Render Nginx configuration file   TAGS: [pledgecamp_tokenbridge_backend]
      Test the Nginx configuration      TAGS: [pledgecamp_tokenbridge_backend]
      Restart nginx     TAGS: [pledgecamp_tokenbridge_backend]
      Render the sudoers file allowing common user restart capability   TAGS: [pledgecamp_tokenbridge_backend]
      Render the SystemD unit file      TAGS: [pledgecamp_tokenbridge_backend]

  play #15 (pledgecamp_tokenbridge_frontend): pledgecamp_tokenbridge_frontend   TAGS: [pledgecamp_tokenbridge_frontend]
    tasks:
      Check switch to see if key setup for {{ domain }}       TAGS: [pledgecamp_tokenbridge_frontend]
      Generate self signed security certificate TAGS: [pledgecamp_tokenbridge_frontend]
      Generate letsencrypt certificate  TAGS: [pledgecamp_tokenbridge_frontend]

  play #16 (apicurio_auth): apicurio_auth       TAGS: [apicurio_auth]
    tasks:
      Check switch to see if user initially created KEYCLOAK_USER_SETUP TAGS: [apicurio_auth]
      Create username {{ username }}    TAGS: [apicurio_auth]
      Create usernamedb TAGS: [apicurio_auth]
      Grant privileges  TAGS: [apicurio_auth]
      Create the remote access rule for the username    TAGS: [apicurio_auth]
      Control Switch: KEYCLOAK_USER_SETUP       TAGS: [apicurio_auth]
      Check switch to see if key setup for {{ domain }}       TAGS: [apicurio_auth]
      Generate self signed security certificate TAGS: [apicurio_auth]
      Generate letsencrypt certificate  TAGS: [apicurio_auth]
      Copy across the Nginx rule        TAGS: [apicurio_auth]
      Restart Nginx to pickup the rule  TAGS: [apicurio_auth]

  play #17 (apicurio_api): apicurio_api TAGS: [apicurio_api]
    tasks:
      Check switch to see if user initially created {{ common_working_path }}/POSTGRESQL_USER_SETUP     TAGS: [apicurio_api]
      Create username {{ username }}    TAGS: [apicurio_api]
      Create usernamedb TAGS: [apicurio_api]
      Grant privileges  TAGS: [apicurio_api]
      Create the remote access rule for the username    TAGS: [apicurio_api]
      Control Switch: APICURIO_USER_SETUP       TAGS: [apicurio_api]
      Check switch to see if key setup for {{ domain }}       TAGS: [apicurio_api]
      Generate self signed security certificate TAGS: [apicurio_api]
      Generate letsencrypt certificate  TAGS: [apicurio_api]
      Copy across the Nginx rule        TAGS: [apicurio_api]
      Restart Nginx to pickup the rule  TAGS: [apicurio_api]
```

## playbook: regular.yml
```
  play #1 (pledgecamp_backend): pledgecamp_backend      TAGS: [pledgecamp_backend]
    tasks:
      pledgecamp_backend : Make sure there is working space     TAGS: [pledgecamp_backend]
      pledgecamp_backend : Check switch pledgecamp_backend_BUILD-{{ pledgecamp_backend_container_tag }} TAGS: [pledgecamp_backend]
      pledgecamp_backend : Preparing Pledgecamp API for distribution    TAGS: [pledgecamp_backend]
      pledgecamp_backend : Record Job number    TAGS: [pledgecamp_backend]
      pledgecamp_backend : Install files in to place    TAGS: [pledgecamp_backend]
      pledgecamp_backend : Perform the python setup     TAGS: [pledgecamp_backend]
      pledgecamp_backend : Get the virtual environment path     TAGS: [pledgecamp_backend]
      set_fact  TAGS: [pledgecamp_backend]
      pledgecamp_backend : Check switch to see if key setup for {{ domain }}  TAGS: [pledgecamp_backend]
      pledgecamp_backend : Generate self signed security certificate    TAGS: [pledgecamp_backend]
      pledgecamp_backend : Generate letsencrypt certificate     TAGS: [pledgecamp_backend]
      pledgecamp_backend : Render the configuration files       TAGS: [pledgecamp_backend]
      pledgecamp_backend : Enable SystemD Service       TAGS: [pledgecamp_backend]
      pledgecamp_backend : Make sure SystemD service started    TAGS: [pledgecamp_backend]
      pledgecamp_backend : Reload Nginx configuration   TAGS: [pledgecamp_backend]

  play #2 (pledgecamp_frontend): pledgecamp_frontend    TAGS: [pledgecamp_frontend]
    tasks:
      pledgecamp_frontend : Make sure there is working space    TAGS: [pledgecamp_frontend]
      pledgecamp_frontend : Check switch PLEDGECAMP_FRONTEND_BUILD      TAGS: [pledgecamp_frontend]
      pledgecamp_frontend : Preparing Pledgecamp frontend for distribution      TAGS: [pledgecamp_frontend]
      pledgecamp_frontend : Record Job number   TAGS: [pledgecamp_frontend]
      pledgecamp_frontend : Install files in to place   TAGS: [pledgecamp_frontend]
      pledgecamp_frontend : Render Nginx configuration file     TAGS: [pledgecamp_frontend]
      pledgecamp_frontend : Reload Nginx configuration  TAGS: [pledgecamp_frontend]

  play #3 (mailhog): mailhog    TAGS: [mailhog]
    tasks:
      mailhog : Render the SystemD      TAGS: [mailhog]
      mailhog : Enable SystemD Service  TAGS: [mailhog]
      mailhog : Make sure SystemD service started       TAGS: [mailhog]

  play #4 (apicurio_auth): apicurio_auth        TAGS: [apicurio_auth]
    tasks:
      apicurio_auth : Pull latest container image {{ apicurio_auth_container_tag }}     TAGS: [apicurio_auth]
      apicurio_auth : Start the API Service     TAGS: [apicurio_auth]

  play #5 (apicurio_api): apicurio_api  TAGS: [apicurio_api]
    tasks:
      apicurio_api : Pull latest container image {{ apicurio_api_container_tag }}       TAGS: [apicurio_api]
      apicurio_api : Start the API Service      TAGS: [apicurio_api]

  play #6 (pledgecamp_tokenbridge_backend): pledgecamp_tokenbridge_backend      TAGS: [pledgecamp_tokenbridge_backend]
    tasks:
      pledgecamp_tokenbridge_backend : Make sure there is working space TAGS: [pledgecamp_tokenbridge_backend]
      pledgecamp_tokenbridge_backend : Check switch PLEDGECAMP_TOKENBRIDGE_BACKEND_BUILD        TAGS: [pledgecamp_tokenbridge_backend]
      pledgecamp_tokenbridge_backend : Preparing Pledgecamp tokenbridge backend for distribution        TAGS: [pledgecamp_tokenbridge_backend]
      pledgecamp_tokenbridge_backend : Record Job number        TAGS: [pledgecamp_tokenbridge_backend]
      pledgecamp_tokenbridge_backend : Install files in to place        TAGS: [pledgecamp_tokenbridge_backend]
      pledgecamp_tokenbridge_backend : Create the environment file fo systemd to pick up on     TAGS: [pledgecamp_tokenbridge_backend]
      pledgecamp_tokenbridge_backend : Install the Node project assets  TAGS: [pledgecamp_tokenbridge_backend]
      pledgecamp_tokenbridge_backend : Enable SystemD Service   TAGS: [pledgecamp_tokenbridge_backend]
      pledgecamp_tokenbridge_backend : Make sure SystemD service started        TAGS: [pledgecamp_tokenbridge_backend]
      pledgecamp_tokenbridge_backend : Run any necessary migrations on the data TAGS: [pledgecamp_tokenbridge_backend]
      pledgecamp_tokenbridge_backend : Reload Nginx configuration       TAGS: [pledgecamp_tokenbridge_backend]
      pledgecamp_tokenbridge_backend : Setup the Deposit watcher cron job       TAGS: [pledgecamp_tokenbridge_backend]
      pledgecamp_tokenbridge_backend : Setup the transfer out cron job  TAGS: [pledgecamp_tokenbridge_backend]
      pledgecamp_tokenbridge_backend : Setup the transaction check cron job     TAGS: [pledgecamp_tokenbridge_backend]

  play #7 (pledgecamp_tokenbridge_frontend): pledgecamp_tokenbridge_frontend    TAGS: [pledgecamp_tokenbridge_frontend]
    tasks:
      Check switch to see if key setup for {{ domain }}       TAGS: [pledgecamp_tokenbridge_frontend]
      Generate self signed security certificate TAGS: [pledgecamp_tokenbridge_frontend]
      Generate letsencrypt certificate  TAGS: [pledgecamp_tokenbridge_frontend]
```