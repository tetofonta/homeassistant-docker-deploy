from requests import get, post, put, patch, delete
import json

#todo from env file
user = 'akadmin'
authentic_host = 'https://auth.tetofonta.local/api/v3'
token = 'admintoken1234'

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
    return _authentik_request('POST', f'/api/v3/core/users/{user_id}/set_password/', {'password': password})

def create_user(**kwargs):
    return _authentik_request('POST', f"/core/users/", kwargs)

def edit_tenant(uuid, **kwargs):
    return _authentik_request('PUT', f"/core/tenants/{uuid}/", kwargs)

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

OAUTH_EXPLICIT=get_flow('default-provider-authorization-explicit-consent')
OAUTH_IMPLICIT=get_flow('default-provider-authorization-implicit-consent')
print(OAUTH_EXPLICIT, OAUTH_IMPLICIT)

#Change web certificate
tenant = get_tenant('authentik-default')
cert = get_certificate('authentik')['pk']
edit_tenant(tenant['tenant_uuid'], web_certificate=cert, domain=tenant['domain'])

#Create groups
hass_group = get_group('hass')
if hass_group is None:
    hass_group = create_group(name="hass", is_superuser=False, users=[], parent=None)

# Create users
teto = get_user('teto')
if teto is None:
    teto = create_user(username='teto', name='teto', is_active=True, email='st@fon.com', groups=[hass_group['pk']]) 
    user_set_password(teto['pk'], 'Qwerty1!')

#create providers
scope_openid = get_scope('openid')
scope_email = get_scope('email')
scope_profile = get_scope('profile')

hass_provider = get_provider('hass-oauth')
if hass_provider is None:
    hass_provider = create_oauth_provider(name='hass-oauth', authorization_flow=OAUTH_EXPLICIT['pk'], access_code_validity='hours=0;min=10', token_validity='hours=0;min=30', property_mappings=[scope_openid['pk']])

code_provider = get_provider('code-proxy')
if code_provider is None:
    code_provider = create_proxy_provider(name='code-proxy', authorization_flow=OAUTH_EXPLICIT['pk'], property_mappings=[scope_openid['pk']], external_host='https://code.tetofonta.local', mode='forward_single')

#create apps
hass_app = get_app('hass-app')
if hass_app is None:
    hass_app = create_app(name='hass-app', slug='hass-app', provider=hass_provider['pk'], policy_engine_mode='any')
print(hass_app)