import os
import json
import logging
logger = logging.getLogger('dashboard')

from nvflare.dashboard.application import init_app

app = init_app()

with app.app_context():

    from nvflare.dashboard.application.store import Store

    logger.info('trying to autoconfigure NVFLARE project')

    if Store.ready():

        resp = Store.get_project()
        logger.debug('resp: %s' % json.dumps(resp, indent=2))
        if resp['status'].lower() != 'ok':
            logger.error("Could not get project from the Store")
            exit(1)

        project = resp['project']
        logger.debug('project: %s' % json.dumps(project, indent=2))

        env_vars = {
            'server1': 'NVFL_SERVER1',
            'server2': 'NVFL_SERVER2',
            'ha_mode': 'NVFL_HA_MODE',
            'short_name': 'NVFL_PROJECT_SHORT_NAME',
            'title': 'NVFL_PROJECT_TITLE',
            'description': 'NVFL_PROJECT_DESCRIPTION',
            'app_location': 'NVFL_PROJECT_APP_LOCATION',
            'starting_date': 'NVFL_PROJECT_STARTING_DATE',
            'end_date': 'NVFL_PROJECT_END_DATE',
            'public': 'NVFL_PROJECT_PUBLIC',
            'frozen': 'NVFL_PROJECT_FROZEN'
        }
        logger.debug('env_vars (mapping from ENVIRONMENT VARIABLES to NVFLARE Dashboard\'s internal):\n%s' % json.dumps(env_vars, indent=2))

        project_conf = {}
        for var, env_var in env_vars.items():
            if env_var in os.environ.keys() and len(os.environ[env_var]) > 0:
                project_conf[var] = os.environ[env_var]
                if var in ['public', 'frozen', 'ha_mode']:
                    project_conf[var] = project_conf[var].lower() in ('true', '1', 't', '${true}')
        logger.debug('project_conf: %s' % json.dumps(project_conf, indent=2))

        if len(project_conf) > 0:
            logger.debug('project: %s' % json.dumps(project, indent=2))
            project.update(project_conf)
            logger.debug('project (updated): %s' % json.dumps(project, indent=2))
            resp = Store.set_project(project)
            logger.debug('resp: %s' % json.dumps(resp, indent=2))
            if resp['status'].lower() != 'ok':
                logger.error('Could not update project configuration')
                exit(1)
            else:
                logger.info('Project configuration updated')
            logger.info('project_conf empty, not updating project')

    logger.error('Store not ready')