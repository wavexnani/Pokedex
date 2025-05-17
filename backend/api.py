from flask import Flask, jsonify, request
from flask_restful import Api, Resource, reqparse
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
import requests

app = Flask(__name__)
CORS(app)
api = Api(app)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///pokemon.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# ------------------ MODELS ------------------

class UserModel(db.Model):
    __tablename__ = 'user_model'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    name = db.Column(db.String(80), nullable=False)
    password = db.Column(db.String(200), nullable=False)  # store hashed password

class CapturedModel(db.Model):
    __tablename__ = 'captured'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user_model.id'), nullable=False)
    name = db.Column(db.String(80), nullable=False)
    imageUrl = db.Column(db.String(200), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    stats = db.Column(db.String(200), nullable=False)
    types = db.Column(db.String(100), nullable=False)
    abilities = db.Column(db.String(200), nullable=False)

class FavoriteModel(db.Model):
    __tablename__ = 'favorite'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user_model.id'), nullable=False)
    name = db.Column(db.String(80), nullable=False)
    imageUrl = db.Column(db.String(200), nullable=False)
    description = db.Column(db.String(500), nullable=False)
    stats = db.Column(db.String(200), nullable=False)
    types = db.Column(db.String(100), nullable=False)
    abilities = db.Column(db.String(200), nullable=False)

# ------------------ PARSERS ------------------

signup_args = reqparse.RequestParser()
signup_args.add_argument('username', type=str, required=True)
signup_args.add_argument('name', type=str, required=True)
signup_args.add_argument('password', type=str, required=True)

login_args = reqparse.RequestParser()
login_args.add_argument('username', type=str, required=True)
login_args.add_argument('password', type=str, required=True)

pokemon_args = reqparse.RequestParser()
pokemon_args.add_argument('user_id', type=int, required=True)
pokemon_args.add_argument('name', type=str, required=True)
pokemon_args.add_argument('imageUrl', type=str, required=True)
pokemon_args.add_argument('description', type=str, required=True)
pokemon_args.add_argument('stats', type=str, required=True)
pokemon_args.add_argument('types', type=str, required=True)
pokemon_args.add_argument('abilities', type=str, required=True)

update_name_args = reqparse.RequestParser()
update_name_args.add_argument('new_name', type=str, required=True)

# ------------------ RESOURCES ------------------

class Signup(Resource):
    def post(self):
        args = signup_args.parse_args()
        if UserModel.query.filter_by(username=args['username']).first():
            return {"message": "Username already exists"}, 409

        hashed_password = generate_password_hash(args['password'])
        user = UserModel(username=args['username'], name=args['name'], password=hashed_password)
        db.session.add(user)
        db.session.commit()
        return {"message": "User created successfully", "user_id": user.id}, 201
    
class Login(Resource):
    def post(self):
        args = login_args.parse_args()
        user = UserModel.query.filter_by(username=args['username']).first()
        if user and check_password_hash(user.password, args['password']):
            return {"message": "Login successful", "user_id": user.id}, 200
        return {"message": "Invalid credentials"}, 401

class AddToCaptured(Resource):
    def post(self):
        args = pokemon_args.parse_args()
        captured = CapturedModel(**args)
        db.session.add(captured)
        db.session.commit()
        return {"message": "Pokémon captured successfully"}, 201

class GetCaptured(Resource):
    def get(self, user_id):
        pokemons = CapturedModel.query.filter_by(user_id=user_id).all()
        results = [{
            "id": p.id,
            "name": p.name,
            "imageUrl": p.imageUrl,
            "description": p.description,
            "stats": p.stats,
            "types": p.types,
            "abilities": p.abilities
        } for p in pokemons]
        return results, 200

class DeleteCaptured(Resource):
    def delete(self, capture_id):
        capture = CapturedModel.query.get(capture_id)
        if not capture:
            return {"message": "Not found"}, 404
        db.session.delete(capture)
        db.session.commit()
        return {"message": "Deleted successfully"}, 200
    
class UpdateCapturedName(Resource):
    def put(self, capture_id):
        args = request.get_json()
        new_name = args.get('new_name')

        if not new_name:
            return {"message": "New name is required"}, 400

        captured = CapturedModel.query.get(capture_id)
        if not captured:
            return {"message": "Captured Pokémon not found"}, 404

        captured.name = new_name
        db.session.commit()
        return {"message": "Captured Pokémon name updated successfully"}, 200
    

class AddToFavorite(Resource):
    def post(self):
        args = pokemon_args.parse_args()
        favorite = FavoriteModel(**args)
        db.session.add(favorite)
        db.session.commit()
        return {"message": "Added to favorites successfully"}, 201

class GetFavorites(Resource):
    def get(self, user_id):
        pokemons = FavoriteModel.query.filter_by(user_id=user_id).all()
        results = [{
            "id": p.id,
            "name": p.name,
            "imageUrl": p.imageUrl,
            "description": p.description,
            "stats": p.stats,
            "types": p.types,
            "abilities": p.abilities
        } for p in pokemons]
        return results, 200
    

class DeleteFavorite(Resource):
    def delete(self, favorite_id):
        favorite = FavoriteModel.query.get(favorite_id)
        if not favorite:
            return {"message": "Not found"}, 404
        db.session.delete(favorite)
        db.session.commit()
        return {"message": "Deleted successfully"}, 200

# ------------------ ROUTES ------------------

api.add_resource(Signup, '/signup')
api.add_resource(Login, '/login')

api.add_resource(GetCaptured, '/captured/<int:user_id>')
api.add_resource(DeleteCaptured, '/captured/delete/<int:capture_id>')
api.add_resource(UpdateCapturedName, '/captured/update-name/<int:capture_id>')

api.add_resource(AddToFavorite, '/favorites/add')
api.add_resource(GetFavorites, '/favorites/<int:user_id>')
api.add_resource(DeleteFavorite, '/favorites/delete/<int:favorite_id>')

@app.route('/captured/<string:username>', methods=['GET'])
def get_captured_pokemons(username):
    user = UserModel.query.filter_by(username=username).first()
    if not user:
        return jsonify({'error': 'User not found'}), 404

    captured_list = CapturedModel.query.filter_by(user_id=user.id).all()

    if not captured_list:
        return jsonify({'message': 'No captured Pokémon found for this user'}), 200

    result = []
    for captured in captured_list:
        result.append({
            'id': captured.id,
            'name': captured.name,
            'imageUrl': captured.imageUrl,
            'description': captured.description,
            'types': captured.types,
            'abilities': captured.abilities,
            'stats': captured.stats,
        })

    return jsonify(result), 200


# This is used to add the pokemons into captured table by there userID.
@app.route('/captured/add', methods=['POST'])
def add_captured_pokemon():
    data = request.get_json()

    # Get username from request
    username = data.get('username')
    if not username:
        return jsonify({'error': 'Username is required'}), 400

    # Find user by username
    user = UserModel.query.filter_by(username=username).first()
    if not user:
        return jsonify({'error': 'User not found'}), 404

    # Create CapturedPokemon with user.id
    captured = CapturedModel(
        user_id=user.id,
        name=data.get('name'),
        imageUrl=data.get('imageUrl'),
        description=data.get('description'),
        stats=data.get('stats'),
        types=data.get('types'),
        abilities=data.get('abilities')
    )

    db.session.add(captured)
    db.session.commit()

    return jsonify({'message': 'Captured Pokémon added successfully'}), 201


# This loads the pokemon which the user searches.
@app.route('/api', methods=['GET'])
def get_pokemon_data():
    query = request.args.get("query")  # Get ?query=mew
    if not query:
        return jsonify({"error": "Missing query parameter"}), 400

    # Fetch base Pokémon details
    url = f"https://pokeapi.co/api/v2/pokemon/{query.lower()}"
    response = requests.get(url)

    if response.status_code != 200:
        return jsonify({"error": f"Failed to fetch Pokémon data for '{query}'"}), 404

    details = response.json()

    # Fetch species details
    species_url = details["species"]["url"]
    species_response = requests.get(species_url)

    if species_response.status_code != 200:
        return jsonify({"error": "Failed to fetch species data"}), 500

    species_details = species_response.json()

    # Prepare the response
    pokemon_entry = {
        'name': details['name'],
        'image': details['sprites']["other"]['official-artwork'].get('front_shiny'),
        'types': [type_info['type']['name'] for type_info in details['types']],
        'abilities': [ability_info['ability']['name'] for ability_info in details['abilities']],
        'stats': {stat_info['stat']['name']: stat_info['base_stat'] for stat_info in details['stats']},
        'description': next(
            (desc['flavor_text'].replace('\n', ' ').replace('\f', ' ')
            for desc in species_details['flavor_text_entries']
            if desc['language']['name'] == 'en'),
            "No description available."
        ),
    }

    return jsonify(pokemon_entry)


# It is useful for checking the username the user enter in trading page.
@app.route('/users/by-username/<string:username>', methods=['GET'])
def get_user_by_username(username):
    user = UserModel.query.filter_by(username=username).first()
    if not user:
        return jsonify({'error': 'User not found'}), 404

    return jsonify({
        'username': user.username,
    }), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)