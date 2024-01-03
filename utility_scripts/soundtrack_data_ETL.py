import pandas as pd
from pathlib import Path

file_path = Path(__file__).resolve().parents[0] / 'data' / 'sound_track_imdb_top_250_movie_tv_series.csv'
print(file_path)
df = pd.read_csv(file_path, delimiter=",", index_col=0)

# filter columns
df_selected = df.loc[:,['name','year','song_name','performed_by']]

# drop all titles without a soundtrack
filter_mask = df_selected['song_name'] == "It looks like we don't have any Soundtracks for this title yet."
df_selected = df_selected[~filter_mask]
df_selected.reset_index(drop=True, inplace=True)

# # Find the titles that exist in more than one year
# movie_counts = df_selected.groupby('name')['year'].nunique()
# movie_counts[movie_counts > 1].index
# duplicate_titles_df = df_selected[df_selected['name'].isin(movie_counts[movie_counts > 1].index)]
# duplicate_titles_df

# manually change title of the duplicate movie names 
df_selected.loc[(df_selected.name == 'The Office') & (df_selected.year == 2005), 'name'] = 'The Office (US)'
df_selected.loc[(df_selected.name == 'The Office') & (df_selected.year == 2001), 'name'] = 'The Office (UK)'
df_selected.loc[(df_selected.name == 'Persona') & (df_selected.year == 1966), 'name'] = 'Persona (1966)'
df_selected.loc[(df_selected.name == 'Persona') & (df_selected.year == 2018), 'name'] = 'Persona (2018)'

# remove leading and trailing whitespace for all string columns
df_selected = df_selected.map(lambda x: x.strip() if isinstance(x, str) else x)

# write df_selected to CSV file (without index)
save_path = Path(__file__).resolve().parents[0] / 'data' / 'filtered_movie_songs_no_idx.csv'
df_selected.to_csv(save_path, index=False)
