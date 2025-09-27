# Data Model: LoL Team Management Dashboard

## Entity Relationships

```
User ||--o{ Team : manages
User ||--o{ Team : captains
Team ||--o{ TeamRoster : has
Player ||--o{ TeamRoster : participates_in
Team ||--o{ TeamTournament : registers_for
Tournament ||--o{ TeamTournament : includes
Player }o--o{ PlayerRole : has_preference
```

## Core Entities

### User

**Purpose**: Represents team managers and team captains with role-based permissions

**Attributes**:

- id: string (UUID)
- username: string (unique)
- email: string (unique)
- role: 'team_manager' | 'team_captain'
- display_name: string
- created_at: timestamp
- updated_at: timestamp

**Validation Rules**:

- Email must be valid format
- Username must be alphanumeric + underscores
- Role must be one of defined enum values
- Display name required, max 50 characters

**State Transitions**:

- Created → Active (after email verification)
- Active → Suspended (if violations)
- Team Captain can be promoted to Team Manager

### Team

**Purpose**: Represents a League of Legends team with roster and tournament participation

**Attributes**:

- id: string (UUID)
- name: string (unique within club)
- captain_id: string (foreign key to User)
- status: 'active' | 'inactive' | 'disbanded'
- division: string (e.g., 'Iron', 'Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond')
- max_roster_size: number (default: 10, 5 starters + 5 substitutes)
- description: text (optional)
- created_at: timestamp
- updated_at: timestamp

**Validation Rules**:

- Name must be unique, 3-30 characters
- Captain must exist and have captain/manager role
- Max roster size between 5-15 players
- Status must be valid enum value

**State Transitions**:

- Created → Active (when first player added)
- Active → Inactive (when season ends)
- Active → Disbanded (when permanently closed)

### Player

**Purpose**: Individual player with skills, preferences, and availability

**Attributes**:

- id: string (UUID)
- summoner_name: string (League of Legends username)
- display_name: string
- email: string (optional)
- discord_username: string (optional)
- skill_level: 'iron' | 'bronze' | 'silver' | 'gold' | 'platinum' | 'diamond' | 'master' | 'grandmaster' | 'challenger'
- availability_status: 'available' | 'busy' | 'unavailable'
- notes: text (internal notes from managers)
- created_at: timestamp
- updated_at: timestamp

**Validation Rules**:

- Summoner name required, 3-16 characters
- Skill level must be valid League rank
- Email format validation if provided
- Availability status must be valid enum

**State Transitions**:

- Pipeline → Assigned (when added to team roster)
- Assigned → Pipeline (when removed from team)
- Available → Busy → Unavailable (availability changes)

### TeamRoster

**Purpose**: Links players to teams with specific roles and starter status

**Attributes**:

- id: string (UUID)
- team_id: string (foreign key to Team)
- player_id: string (foreign key to Player)
- role: 'top' | 'jungle' | 'mid' | 'adc' | 'support' | 'fill'
- is_starter: boolean
- joined_at: timestamp
- position_notes: text (optional)

**Validation Rules**:

- Team can have max 1 starter per role (except fill)
- Player can only be on one team at a time
- Role must be valid League of Legends position
- Team cannot exceed max_roster_size

**State Transitions**:

- Added → Starter (when promoted)
- Starter → Substitute (when demoted)
- Removed (when player leaves team)

### PlayerRole

**Purpose**: Tracks player's preferred roles and proficiency

**Attributes**:

- id: string (UUID)
- player_id: string (foreign key to Player)
- role: 'top' | 'jungle' | 'mid' | 'adc' | 'support'
- proficiency: 'learning' | 'comfortable' | 'proficient' | 'expert'
- is_primary: boolean (one primary role per player)

**Validation Rules**:

- Player can have multiple role preferences
- Only one primary role per player
- Proficiency must be valid level
- Role must be valid League position

### Tournament

**Purpose**: External tournaments that teams can register for

**Attributes**:

- id: string (UUID)
- external_id: string (from tournament platform)
- name: string
- platform: 'riot_games' | 'battlefy' | 'toornament' | 'challonge' | 'custom'
- start_date: date
- end_date: date
- registration_deadline: timestamp
- max_teams: number (optional)
- entry_fee: decimal (optional)
- prize_pool: decimal (optional)
- rules_url: string (optional)
- status: 'upcoming' | 'registration_open' | 'registration_closed' | 'in_progress' | 'completed' | 'cancelled'
- sync_status: 'synced' | 'pending' | 'error' | 'manual'
- created_at: timestamp
- updated_at: timestamp

**Validation Rules**:

- External ID unique per platform
- Start date must be after registration deadline
- End date must be after start date
- Platform must be supported type

**State Transitions**:

- Created → Registration Open → Registration Closed → In Progress → Completed
- Any state → Cancelled (if tournament cancelled)

### TeamTournament

**Purpose**: Links teams to tournaments with registration status

**Attributes**:

- id: string (UUID)
- team_id: string (foreign key to Team)
- tournament_id: string (foreign key to Tournament)
- registration_status: 'registered' | 'waitlisted' | 'confirmed' | 'withdrawn'
- registered_at: timestamp
- roster_snapshot: json (team roster at registration time)
- placement: number (optional, final tournament placement)

**Validation Rules**:

- Team can only register once per tournament
- Registration must be before deadline
- Roster snapshot required at registration
- Placement only valid after tournament completion

## PostgreSQL Database Indexes

**Performance Optimizations**:

- Composite index on team_rosters(team_id, role) for roster queries
- Composite index on players(skill_level, availability_status) for pipeline filtering
- Composite index on tournaments(status, registration_deadline) for active tournaments
- Composite index on team_tournaments(team_id, tournament_id) for team tournament history
- GIN index on players(summoner_name, display_name) for full-text search
- Index on users(email) for authentication queries
- Index on teams(captain_id) for captain-based queries
- Index on tournaments(platform, external_id) for external platform synchronization

## PostgreSQL Data Integrity Constraints

**Foreign Key Constraints with Referential Integrity**:

- teams.captain_id → users.id (ON DELETE RESTRICT)
- team_rosters.team_id → teams.id (ON DELETE CASCADE)
- team_rosters.player_id → players.id (ON DELETE CASCADE)
- player_roles.player_id → players.id (ON DELETE CASCADE)
- team_tournaments.team_id → teams.id (ON DELETE CASCADE)
- team_tournaments.tournament_id → tournaments.id (ON DELETE RESTRICT)

**Database-Level Constraints**:

- UNIQUE constraint on users(email) and users(username)
- UNIQUE constraint on teams(name) within organization scope
- UNIQUE constraint on players(summoner_name)
- CHECK constraint on teams.max_roster_size BETWEEN 5 AND 15
- CHECK constraint on tournaments.end_date > tournaments.start_date
- CHECK constraint on tournaments.start_date > tournaments.registration_deadline

**Business Logic Constraints (enforced in application layer)**:

- Team cannot exceed max_roster_size (validated in Express.js routes)
- Player cannot be on multiple teams simultaneously (validated in teamService)
- Only one starter per role per team except 'fill' (validated in roster management)
- Tournament registration only allowed before deadline (validated in tournamentService)
- Team captain must have 'team_captain' or 'team_manager' role (validated in auth middleware)
