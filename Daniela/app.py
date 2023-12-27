from flask import Flask, render_template, request
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import func  # Import the func module for case-insensitive comparison
from sqlalchemy.orm import aliased

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:Db2023@localhost/soundtrack_project' #here we can to figure out keeping secrets
db = SQLAlchemy(app)

class Artist(db.Model):
    __tablename__ ='artists'
    artist_id = db.Column(db.Integer, primary_key=True)
    artist_name = db.Column(db.String(100), nullable=False)

class Movie(db.Model):
    __tablename__ = 'movies'
    movie_id = db.Column(db.Integer, primary_key=True)
    movie_name = db.Column(db.String(100), nullable=False)
    release_year = db.Column(db.Integer, nullable=False)

class MovieRecording(db.Model):
    __tablename__ ='movies_recordings'
    movie_id = db.Column(db.Integer, db.ForeignKey('movies.movie_id'), primary_key=True)
    recording_id = db.Column(db.Integer, db.ForeignKey('recordings.recording_id'), primary_key=True)

class Recording(db.Model):
    __tablename__ ='recordings'
    recording_id = db.Column(db.Integer, primary_key=True)
    song_name = db.Column(db.String(100), nullable=False)
    artist_id = db.Column(db.Integer, db.ForeignKey('artists.artist_id'), nullable=False)

    # Adjust the relationship definition with explicit join condition
    artist = db.relationship('Artist', backref=db.backref('recordings', lazy=True), primaryjoin="Recording.artist_id == Artist.artist_id")


@app.route('/')
def index():
    return render_template('index.html')

@app.route('/search', methods=['POST'])
def search():
    movie_name = request.form.get('movie_name')
    if movie_name:
        # Use func.lower for case-insensitive comparison
        movie = Movie.query.filter(func.lower(Movie.movie_name) == func.lower(movie_name)).first()
        if movie:
            # Explicitly alias the MovieRecording table for clarity
            movie_recording_alias = aliased(MovieRecording)

            # Explicitly specify the join condition in the query
            recordings = db.session.query(Recording)\
                .join(movie_recording_alias, Recording.recording_id == movie_recording_alias.recording_id)\
                .filter(movie_recording_alias.movie_id == movie.movie_id).all()

            return render_template('results.html', movie=movie, recordings=recordings)
        else:
            return render_template('index.html', error="Movie not found.")

    return render_template('index.html', error="Movie name not provided.")

if __name__ == '__main__':
    app.run(debug=True)
