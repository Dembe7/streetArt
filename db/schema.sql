CREATE TABLE userpost (
    id SERIAL PRIMARY KEY,
    image_url TEXT, 
    location TEXT,
    caption TEXT,
    user_art INTEGER,
    title TEXT
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT,
    email TEXT,
    password_digest TEXT
);

-- INSERT INTO  userpost (image_url, location, caption, title) VALUES ('https://static.artfido.com/2015/08/Street-Art-Collection-Banksy-32.jpg', 'U.K', 'Man on wall', 'Whatever' );