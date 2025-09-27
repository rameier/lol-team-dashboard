-- Initialize LoL Team Management Dashboard Database
-- This script sets up the initial database structure

-- Create database (this will be handled by Docker environment)
-- CREATE DATABASE lol_team_dashboard;

-- Connect to the database
-- \c lol_team_dashboard;

-- Enable UUID extension for primary keys
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create enum types
CREATE TYPE user_role AS ENUM ('admin', 'team_manager', 'player', 'viewer');
CREATE TYPE match_status AS ENUM ('scheduled', 'in_progress', 'completed', 'cancelled');
CREATE TYPE player_position AS ENUM ('top', 'jungle', 'mid', 'adc', 'support');

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role user_role NOT NULL DEFAULT 'viewer',
    avatar_url VARCHAR(500),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Teams table
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    tag VARCHAR(10) NOT NULL,
    logo_url VARCHAR(500),
    description TEXT,
    region VARCHAR(50),
    manager_id UUID REFERENCES users(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Players table (extends users for LoL-specific data)
CREATE TABLE players (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    team_id UUID REFERENCES teams(id) ON DELETE SET NULL,
    summoner_name VARCHAR(50) NOT NULL,
    position player_position,
    rank VARCHAR(50),
    lp INTEGER DEFAULT 0,
    champion_pool TEXT[], -- Array of favorite champions
    is_starter BOOLEAN DEFAULT false,
    joined_team_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Matches table
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    home_team_id UUID REFERENCES teams(id) NOT NULL,
    away_team_id UUID REFERENCES teams(id) NOT NULL,
    scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    status match_status DEFAULT 'scheduled',
    home_team_score INTEGER DEFAULT 0,
    away_team_score INTEGER DEFAULT 0,
    tournament_name VARCHAR(100),
    match_format VARCHAR(20) DEFAULT 'Bo1', -- Bo1, Bo3, Bo5
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT different_teams CHECK (home_team_id != away_team_id)
);

-- Match games (individual games within a match)
CREATE TABLE match_games (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
    game_number INTEGER NOT NULL,
    winning_team_id UUID REFERENCES teams(id),
    duration_minutes INTEGER,
    game_data JSONB, -- Store detailed game statistics
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(match_id, game_number)
);

-- Player statistics per game
CREATE TABLE player_game_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    game_id UUID REFERENCES match_games(id) ON DELETE CASCADE,
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    champion VARCHAR(50) NOT NULL,
    kills INTEGER DEFAULT 0,
    deaths INTEGER DEFAULT 0,
    assists INTEGER DEFAULT 0,
    cs INTEGER DEFAULT 0,
    damage_dealt INTEGER DEFAULT 0,
    damage_taken INTEGER DEFAULT 0,
    gold_earned INTEGER DEFAULT 0,
    vision_score INTEGER DEFAULT 0,
    items TEXT[], -- Array of item names
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(game_id, player_id)
);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_players_team_id ON players(team_id);
CREATE INDEX idx_players_summoner_name ON players(summoner_name);
CREATE INDEX idx_matches_home_team ON matches(home_team_id);
CREATE INDEX idx_matches_away_team ON matches(away_team_id);
CREATE INDEX idx_matches_scheduled_at ON matches(scheduled_at);
CREATE INDEX idx_match_games_match_id ON match_games(match_id);
CREATE INDEX idx_player_game_stats_game_id ON player_game_stats(game_id);
CREATE INDEX idx_player_game_stats_player_id ON player_game_stats(player_id);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_teams_updated_at BEFORE UPDATE ON teams FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_players_updated_at BEFORE UPDATE ON players FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default admin user (password: admin123 - should be changed in production)
INSERT INTO users (email, password_hash, username, full_name, role) 
VALUES (
    'admin@lolteam.local',
    '$2b$10$rQJ0D5C2Jt2V9QnK7X8xXeJ0K2H5jF8nQ3M9L6P7R4S1T8U9V0W1X2', -- admin123
    'admin',
    'System Administrator',
    'admin'
);

-- Create database user for the application (this would typically be done outside the init script)
-- This is commented out as it should be handled by Docker environment variables
-- CREATE USER lol_app WITH PASSWORD 'secure_password_here';
-- GRANT CONNECT ON DATABASE lol_team_dashboard TO lol_app;
-- GRANT USAGE ON SCHEMA public TO lol_app;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO lol_app;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO lol_app;