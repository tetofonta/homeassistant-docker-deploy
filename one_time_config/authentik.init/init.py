from requests import get, post, put, patch, delete
import json
import os
import time

#todo from env file
authentic_host = f'https://{os.environ["AK_HOST"]}:{os.environ["AK_PORT"]}/api/v3'
token = os.environ['AK_ADMIN_TOKEN']

print(authentic_host, token)

def _authentik_request(method, url, data={}):
    #todo handle pagination
    if method == 'GET':
        req = get(authentic_host+url, headers={'Authorization': f"Bearer {token}", 'Accept': 'application/json'}, verify=False)
        print(req.status_code, req.content)
        return json.loads(req.content) if req.status_code == 200 or req.status_code == 201 else {}
    if method == 'PUT':
        req = put(authentic_host+url, data=json.dumps(data), headers={'Authorization': f"Bearer {token}", 'Accept': 'application/json', 'Content-Type': 'application/json'}, verify=False)
        print(url, req.status_code, req.content, data)
        return json.loads(req.content) if req.status_code == 200 or req.status_code == 201 else {}
    if method == 'POST':
        req = post(authentic_host+url, data=json.dumps(data), headers={'Authorization': f"Bearer {token}", 'Accept': 'application/json', 'Content-Type': 'application/json'}, verify=False)
        print(url, req.status_code, req.content, data)
        return json.loads(req.content) if req.status_code == 200 or req.status_code == 201 else {}

def get_group(group_name):
    data = _authentik_request('GET', f"/core/groups/?name={group_name.replace(' ', '+')}")
    return data['results'][0] if 'results' in data and len(data['results']) > 0 else None

def create_group(**kwargs):
    return _authentik_request('POST', f"/core/groups/", kwargs)

def get_tenant(domain):
    data = _authentik_request('GET', f"/core/tenants/?domain={domain}")
    return data['results'][0] if 'results' in data and len(data['results']) > 0 else None

def get_certificate(name):
    data = _authentik_request('GET', f"/crypto/certificatekeypairs/?name={name.replace(' ', '+')}")
    return data['results'][0] if 'results' in data and len(data['results']) > 0 else None

def get_user(username):
    data = _authentik_request('GET', f'/core/users/?username={username}')
    return data['results'][0] if 'results' in data and len(data['results']) > 0 else None

def user_set_password(user_id, password):
    return _authentik_request('POST', f'/core/users/{user_id}/set_password/', {'password': password})

def create_user(**kwargs):
    return _authentik_request('POST', f"/core/users/", kwargs)

def edit_tenant(uuid, **kwargs):
    return _authentik_request('PUT', f"/core/tenants/{uuid}/", kwargs)

def edit_tenant(uuid, **kwargs):
    return _authentik_request('PUT', f"/core/tenants/{uuid}/", kwargs)

def get_outpost(search):
    data = _authentik_request('GET', f'/outposts/instances/?username={search}')
    return data['results'][0] if 'results' in data and len(data['results']) > 0 else None

def edit_outpost(uuid, **kwargs):
    return _authentik_request('PUT', f"/outposts/instances/{uuid}/", kwargs)

def get_provider(search):
    data = _authentik_request('GET', f'/providers/all/?search={search}')
    return data['results'][0] if 'results' in data and len(data['results']) > 0 else None

def get_scope(scope_name):
    data = _authentik_request('GET', f'/propertymappings/scope/?scope_name={scope_name}')
    return data['results'][0] if 'results' in data and len(data['results']) > 0 else None

def get_app(search):
    data = _authentik_request('GET', f'/core/applications/?search={search}')
    return data['results'][0] if 'results' in data and len(data['results']) > 0 else None

def create_app(**kwargs):
    return _authentik_request('POST', f"/core/applications/", kwargs)

def create_oauth_provider(**kwargs):
    return _authentik_request('POST', f"/providers/oauth2/", kwargs)

def create_proxy_provider(**kwargs):
    return _authentik_request('POST', f"/providers/proxy/", kwargs)

def get_flow(name):
    data = _authentik_request('GET', f'/flows/instances/?search={name}')
    return data['results'][0] if 'results' in data and len(data['results']) > 0 else None

def wait_for_node():
    while True:
        try:
            print('waiting...')
            data = get(f'https://{os.environ["AK_HOST"]}:{os.environ["AK_PORT"]}/-/health/ready/', headers={'User-Agent': 'goauthentik.io lifecycle Healthcheck', 'Authorization': f"Bearer {token}", 'Accept': 'application/json'}, verify=False)
            print(data)
            if data.status_code == 204:
                break
        except Exception as e:
            print(e)
        time.sleep(2)
    time.sleep(1)

wait_for_node()

def mk_group(name, parent=None, **kwargs):
    group = get_group(name)
    if group is None:
        group = create_group(name=name, parent=parent['pk'] if parent is not None else None, users=[], **kwargs)
    return group

def mk_user(username, name, email, password, groups, **kwargs):
    user = get_user(username)
    if user is None:
        user = create_user(username=username, name=name, is_active=True, email=email, groups=list(map(lambda x: x['pk'], groups)), **kwargs) 
        user_set_password(user['pk'], password)
    return user

def mk_oauth_provider(name, flow, scopes, **kwargs):
    prov = get_provider(name)
    if prov is None:
        prov = create_oauth_provider(name=name, authorization_flow=flow['pk'], property_mapping=list(map(lambda x: x['pk'], scopes)), **kwargs)
    return prov

def mk_app(name, slug, provider, **kwargs):
    app = get_app(name)
    if app is None:
        app = create_app(name=name, slug=slug, provider=provider['pk'], **kwargs)
    return app

def mk_proxy_app(name, slug, flow, **kwargs):
    prov = get_provider(name + "-proxy")
    if prov is None:
        prov = create_proxy_provider(name=name + "-proxy", authorization_flow=flow['pk'], mode='forward_single', **kwargs)
    app = mk_app(name, slug, prov, **kwargs)
    out = get_outpost('authentik Embedded Outpost')
    edit_outpost(out['pk'], name='authentik Embedded Outpost', type='proxy', providers=out['providers'] + [prov['pk']], config=out['config'])
    return app

def mk_oauth_app(name, slug, flow, scopes, **kwargs):
    prov = get_provider(name + "-oauth")
    if prov is None:
        prov = create_oauth_provider(name=name + "-oauth", authorization_flow=flow['pk'], property_mappings=list(map(lambda x: x['pk'], scopes)), **kwargs)
    app = mk_app(name, slug, prov, **kwargs)
    return app
#=======================================================================================================================================
OAUTH_EXPLICIT=get_flow('default-provider-authorization-explicit-consent')
OAUTH_IMPLICIT=get_flow('default-provider-authorization-implicit-consent')
scope_openid = get_scope('openid')
scope_email = get_scope('email')
scope_profile = get_scope('profile')

hass_group = mk_group('homeassistant')
hass_admin = mk_group('homeassistantadmin', hass_group)
management_group = mk_group('management')

main_user = mk_user(f"{os.environ['HASS_USERNAME']}", f"{os.environ['HASS_NAME']}", f"{os.environ['HASS_EMAIL']}", f"{os.environ['HASS_PASSWORD']}", [hass_admin, management_group])

#hass
mk_proxy_app(
    'homeassistant', 
    'hass-app', 
    OAUTH_EXPLICIT, 
    external_host=f"{os.environ['HASS_URL']}", 
    meta_launch_url=f"{os.environ['HASS_URL']}",
    meta_description="HomeAssistant",
    group="homeassistant"
)

#pgadmin
mk_oauth_app(
    'pgadmin', 
    'pgadmin-app', 
    OAUTH_EXPLICIT, 
    [scope_email, scope_profile, scope_openid], 
    client_id=os.environ['PGADMIN_OAUTH_CLIENT_ID'], 
    client_secret=os.environ['PGADMIN_OAUTH_CLIENT_SECRET'], 
    redirect_uris=f"{os.environ['PGADMIN_URL']}oauth2/authorize",
    meta_launch_url=f"{os.environ['PGADMIN_URL']}",
    meta_description="PGAdmin",
    group="management"
)