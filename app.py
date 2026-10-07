from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify ({"mensagem": "Bem-vindo a API FastOrder!"})

@app.route('/api/status')
def status():
    return jsonify({"status": "Operacional", "Serviço": "Fastorder-Web"})

# TODO: Missão 5.1 - Crie uma nova rota chamada /api/soma
# Ela deve receber dois parâmetros via Query String (?a=2&b=3)
# E retornar um JSON no formato {"resultado": 5}

@app.route('/api/soma')
def soma():
    a = int(request.args.get('a'))
    b = int(request.args.get('b'))

    resultado = a + b

    return jsonify({"resultado": resultado})
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)