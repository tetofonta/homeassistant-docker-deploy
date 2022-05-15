import os

AUTHENTICATION_SOURCES = ['oauth2']
OAUTH2_AUTO_CREATE_USER = True
OAUTH2_CONFIG = [{
    'OAUTH2_NAME' : 'authentik',
    'OAUTH2_DISPLAY_NAME' : 'Authentik SSO',
    'OAUTH2_CLIENT_ID' : os.environ['PGADMIN_OAUTH_CLIENT_ID'],
    'OAUTH2_CLIENT_SECRET' : os.environ['PGADMIN_OAUTH_CLIENT_SECRET'],
    'OAUTH2_TOKEN_URL' : os.environ['PGADMIN_TOKEN_URL'],
    'OAUTH2_AUTHORIZATION_URL' : os.environ['PGADMIN_AUTH_URL'],
    'OAUTH2_API_BASE_URL' : os.environ['PGADMIN_API_BASE'],
    'OAUTH2_USERINFO_ENDPOINT' : os.environ['PGADMIN_USERINFO_URL'],
    'OAUTH2_SCOPE' : 'openid email profile',
    'OAUTH2_ICON' : 'fa-brands fa-openid',
    'OAUTH2_BUTTON_COLOR' : '#fd4b2d'
}]