import pytest
from app import app

# Cria um cliente de teste falso para não precisarmos subir o servidor real

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_status_code(client):
    resposta = client.get('/')
    assert resposta.status_code == 200

# TODO: Missão 6.1 Crie um teste para a sua rota /api/soma
# Dica: chame client.get('/api/soma?a=10&b=5')
# Verifique se o status code é 200 e se o JSON retornado tem "resultado" igual a 15.
def test_soma(client):
    resposta = client.get('/api/soma?a=10&b=20')
    dados = resposta.get_json()
    assert resposta.status_code == 200
    assert dados['resultado'] == 30.0

# Teste 1: rota /api/desconto retorna 403 quando a Flag está desativada
def test_desconto_desativado(client, monkeypatch):
    import app as app_module
    monkeypatch.setattr(app_module, 'FEATURE_DESCONTO_PROMO', False)

    resposta = client.get('/api/desconto?valor=100&porcentagem=15')
    assert resposta.status_code == 403
    dados = resposta.get_json()
    assert dados['flag_status'] is False


# Teste 2: rota /api/desconto retorna 200 quando a Flag está ativada
def test_desconto_ativado(client, monkeypatch):
    import app as app_module
    monkeypatch.setattr(app_module, 'FEATURE_DESCONTO_PROMO', True)

    resposta = client.get('/api/desconto?valor=100&porcentagem=15')
    assert resposta.status_code == 200
    dados = resposta.get_json()
    assert dados['valor_final'] == 85.0