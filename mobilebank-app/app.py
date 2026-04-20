from flask import Flask, jsonify
import os
 
app = Flask(__name__)
 
@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "healthy"}), 200
 
@app.route('/api/accounts', methods=['GET'])
def get_accounts():
    return jsonify({
        "accounts": [
            {"id": 1, "name": "Checking", "balance": 1500},
            {"id": 2, "name": "Savings", "balance": 5000}
        ]
    }), 200
 
@app.route('/api/transfer', methods=['POST'])
def transfer():
    return jsonify({
        "status": "success",
        "message": "Transfer completed"
    }), 200
 
if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)