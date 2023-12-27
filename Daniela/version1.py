from flask import Flask, render_template, request
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:Db241305@localhost:5432/movie_soundtrack'
# Replace 'your_username' and 'your_password' with your PostgreSQL username and password
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class Movie(db.Model):
    movie_id = db.Column(db.Integer, primary_key=True)
    movie_name = db.Column(db.String(255), nullable=False)
    release_date = db.Column(db.Date, nullable=False)

class Artist(db.Model):
    artist_id = db.Column(db.Integer, primary_key=True)
    artist_name = db.Column(db.String(255), nullable=False)

class Recording(db.Model):
    recording_id = db.Column(db.Integer, primary_key=True)
    song_name = db.Column(db.String(255), nullable=False)
    artist_id = db.Column(db.Integer, db.ForeignKey('artist.artist_id'), nullable=False)
    artist = db.relationship('Artist', backref=db.backref('recordings', lazy=True))

class MovieRecording(db.Model):
    movie_id = db.Column(db.Integer, db.ForeignKey('movie.movie_id'), primary_key=True)
    recording_id = db.Column(db.Integer, db.ForeignKey('recording.recording_id'), primary_key=True)
    movie = db.relationship('Movie', backref=db.backref('movie_recordings', lazy=True))
    recording = db.relationship('Recording', backref=db.backref('movie_recordings', lazy=True))

# Define routes
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/search', methods=['GET', 'POST'])
def search():
    if request.method == 'POST':
        search_term = request.form['search_term']
        movies = Movie.query.filter(Movie.movie_name.ilike(f'%{search_term}%')).all()
        recordings = Recording.query.filter(Recording.song_name.ilike(f'%{search_term}%')).all()
        return render_template('results.html', movies=movies, recordings=recordings)
    return render_template('search.html')

if __name__ == '__main__':
    app.run(debug=True)
