# Player Pipeline API Contract

## GET /api/players/pipeline

**Purpose**: Get players available for team assignment

**Request**:

```typescript
interface GetPipelineQuery {
  role?: "top" | "jungle" | "mid" | "adc" | "support";
  skill_level?:
    | "iron"
    | "bronze"
    | "silver"
    | "gold"
    | "platinum"
    | "diamond"
    | "master"
    | "grandmaster"
    | "challenger";
  availability?: "available" | "busy" | "unavailable";
  search?: string; // search by summoner_name or display_name
  limit?: number; // default: 20, max: 50
  offset?: number; // default: 0
}
```

**Response** (200 OK):

```typescript
interface GetPipelineResponse {
  players: PipelinePlayer[];
  total: number;
  hasMore: boolean;
  filters: {
    roles: string[];
    skill_levels: string[];
    availability_statuses: string[];
  };
}

interface PipelinePlayer {
  id: string;
  summoner_name: string;
  display_name: string;
  email?: string;
  discord_username?: string;
  skill_level: string;
  availability_status: string;
  preferred_roles: PlayerRole[];
  notes?: string;
  created_at: string;
  updated_at: string;
}

interface PlayerRole {
  role: string;
  proficiency: "learning" | "comfortable" | "proficient" | "expert";
  is_primary: boolean;
}
```

**Error Responses**:

- 400: Invalid query parameters
- 401: Unauthorized access

## POST /api/players

**Purpose**: Add new player to pipeline

**Request**:

```typescript
interface CreatePlayerRequest {
  summoner_name: string; // 3-16 characters, unique
  display_name: string;
  email?: string;
  discord_username?: string;
  skill_level: string;
  availability_status?: string; // defaults to 'available'
  preferred_roles: CreatePlayerRole[];
  notes?: string;
}

interface CreatePlayerRole {
  role: "top" | "jungle" | "mid" | "adc" | "support";
  proficiency: "learning" | "comfortable" | "proficient" | "expert";
  is_primary: boolean;
}
```

**Response** (201 Created):

```typescript
interface CreatePlayerResponse {
  player: PipelinePlayer;
  message: string;
}
```

**Error Responses**:

- 400: Validation errors (summoner name taken, invalid email, etc.)
- 401: Unauthorized
- 422: Business logic violations (no primary role, duplicate roles)

## GET /api/players/:playerId

**Purpose**: Get detailed player information

**Response** (200 OK):

```typescript
interface PlayerDetailResponse {
  player: PlayerDetail;
}

interface PlayerDetail extends PipelinePlayer {
  team_history: PlayerTeamHistory[];
  tournament_history: PlayerTournamentHistory[];
}

interface PlayerTeamHistory {
  team: {
    id: string;
    name: string;
  };
  role: string;
  was_starter: boolean;
  joined_at: string;
  left_at?: string;
}

interface PlayerTournamentHistory {
  tournament: {
    id: string;
    name: string;
    platform: string;
  };
  team: {
    id: string;
    name: string;
  };
  placement?: number;
  participated_at: string;
}
```

**Error Responses**:

- 404: Player not found

## PUT /api/players/:playerId

**Purpose**: Update player information

**Request**:

```typescript
interface UpdatePlayerRequest {
  display_name?: string;
  email?: string;
  discord_username?: string;
  skill_level?: string;
  availability_status?: string;
  preferred_roles?: CreatePlayerRole[];
  notes?: string;
}
```

**Response** (200 OK):

```typescript
interface UpdatePlayerResponse {
  player: PipelinePlayer;
  message: string;
}
```

**Error Responses**:

- 400: Validation errors
- 404: Player not found
- 422: Business logic violations

## DELETE /api/players/:playerId

**Purpose**: Remove player from system

**Response** (200 OK):

```typescript
interface DeletePlayerResponse {
  message: string;
  deleted_player: {
    id: string;
    summoner_name: string;
  };
}
```

**Error Responses**:

- 404: Player not found
- 422: Cannot delete (player currently on team roster)
