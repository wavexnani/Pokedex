from flask import Flask, jsonify, request
import requests
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_restful import Resource, Api, reqparse, fields, marshal_with, abort

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
db = SQLAlchemy(app)
CORS(app)
api = Api(app)


class UserModel (db.Model):
    id = db.Column(db.Integer, primary_key = True)
    name = db.Column(db.String(80), unique = True, nullable = False)
    email = db.Column(db.String(80), unique = True, nullable = False)

    def __repr__ (self):
        return f"User(name = {self.name}, email = {self.email})"
    
class FavoriteModel(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user_model.id'), nullable=False)

    name = db.Column(db.String(80), nullable=False)
    image_url = db.Column(db.String(300), nullable=False)
    description = db.Column(db.Text, nullable=False)

    types = db.Column(db.PickleType, nullable=False)        # ['Fire', 'Flying']
    abilities = db.Column(db.PickleType, nullable=False)    # ['Blaze', 'Solar Power']
    stats = db.Column(db.PickleType, nullable=False)        # {'HP': 78, 'Attack': 84, ...}

    user = db.relationship('UserModel', backref='favorites')


class CapturedModel(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user_model.id'), nullable=False)

    name = db.Column(db.String(80), nullable=False)
    image_url = db.Column(db.String(300), nullable=False)
    description = db.Column(db.Text, nullable=False)

    types = db.Column(db.PickleType, nullable=False)
    abilities = db.Column(db.PickleType, nullable=False)
    stats = db.Column(db.PickleType, nullable=False)

    user = db.relationship('UserModel', backref='captured')


user_args = reqparse.RequestParser()
user_args.add_argument('name', type=str, required=True, help = "Name cannot be empty")
user_args.add_argument('email', type=str, required=True, help = "email cannot be empty")

# For Favorite Pokémon
favorite_args = reqparse.RequestParser()
favorite_args.add_argument('user_id', type=int, required=True)
favorite_args.add_argument('name', type=str, required=True)
favorite_args.add_argument('image_url', type=str, required=True)
favorite_args.add_argument('description', type=str, required=True)
favorite_args.add_argument('types', type=list, location='json', required=True)
favorite_args.add_argument('abilities', type=list, location='json', required=True)
favorite_args.add_argument('stats', type=dict, location='json', required=True)

# For Captured Pokémon
captured_args = reqparse.RequestParser()
captured_args.add_argument('user_id', type=int, required=True)
captured_args.add_argument('name', type=str, required=True)
captured_args.add_argument('image_url', type=str, required=True)
captured_args.add_argument('description', type=str, required=True)
captured_args.add_argument('types', type=list, location='json', required=True)
captured_args.add_argument('abilities', type=list, location='json', required=True)
captured_args.add_argument('stats', type=dict, location='json', required=True)



userFields = {
    'id' : fields.Integer,
    'name' : fields.String,
    'email' : fields.String,  
}


favoriteFields = {
    'id': fields.Integer,
    'user_id': fields.Integer,
    'name': fields.String,
    'image_url': fields.String,
    'description': fields.String,
    'types': fields.List(fields.String),
    'abilities': fields.List(fields.String),
    'stats': fields.Raw  # because it's a dictionary
}

capturedFields = {
    'id': fields.Integer,
    'user_id': fields.Integer,
    'name': fields.String,
    'image_url': fields.String,
    'description': fields.String,
    'types': fields.List(fields.String),
    'abilities': fields.List(fields.String),
    'stats': fields.Raw
}

class Favorites(Resource):
    @marshal_with(favoriteFields)
    def get(self):
        return FavoriteModel.query.all()

    @marshal_with(favoriteFields)
    def post(self):
        args = favorite_args.parse_args()
        favorite = FavoriteModel(**args)
        db.session.add(favorite)
        db.session.commit()
        return favorite, 201

class Captured(Resource):
    @marshal_with(capturedFields)
    def get(self):
        return CapturedModel.query.all(), 200

    @marshal_with(capturedFields)
    def post(self):
        args = captured_args.parse_args()
        captured = CapturedModel(**args)
        db.session.add(captured)
        db.session.commit()
        return captured, 201


class Users(Resource):
    @marshal_with(userFields)
    def get(self):
        users = UserModel.query.all()
        return users
    
    @marshal_with(userFields)
    def post(self):
        args = user_args.parse_args()
        user = UserModel(name=args["name"], email=args["email"])
        db.session.add(user)
        db.session.commit()
        users = UserModel.query.all()
        return users, 201
    

api.add_resource(Users,'/users')
api.add_resource(Favorites, '/favorites')
api.add_resource(Captured, '/captured')


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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)