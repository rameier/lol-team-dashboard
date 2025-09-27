# Team Management API Contract

## GET /api/teams

**Purpose**: Retrieve all teams for dashboard overview

**Request**:

```typescript
// Query parameters
interface GetTeamsQuery {
  status?: "active" | "inactive" | "disbanded";
  limit?: number; // default: 10, max: 10
  offset?: number; // default: 0
}
```

**Response** (200 OK):

```typescript
interface GetTeamsResponse {
  teams: Team[];
  total: number;
  hasMore: boolean;
}

interface Team {
  id: string;
  name: string;
  status: "active" | "inactive" | "disbanded";
  division: string;
  captain: {
    id: string;
    display_name: string;
  };
  roster_count: number;
  starter_count: number;
  upcoming_tournaments: number;
  created_at: string; // ISO timestamp
  updated_at: string; // ISO timestamp
}
```

**Error Responses**:

- 400: Invalid query parameters
- 401: Unauthorized access
- 500: Internal server error

## POST /api/teams

**Purpose**: Create a new team

**Request**:

```typescript
interface CreateTeamRequest {
  name: string; // 3-30 characters, unique
  captain_id: string; // must be valid user ID
  division?: string; // optional, defaults to 'Unranked'
  description?: string; // optional
}
```

**Response** (201 Created):

```typescript
interface CreateTeamResponse {
  team: Team;
  message: string;
}
```

**Error Responses**:

- 400: Validation errors (name taken, invalid captain, etc.)
- 401: Unauthorized (only team managers can create teams)
- 422: Business logic violations (team limit reached)

## GET /api/teams/:teamId

**Purpose**: Get detailed team information including roster

**Response** (200 OK):

```typescript
interface TeamDetailResponse {
  team: TeamDetail;
}

interface TeamDetail extends Team {
  roster: RosterMember[];
  tournaments: TeamTournament[];
  description?: string;
}

interface RosterMember {
  id: string;
  player: {
    id: string;
    summoner_name: string;
    display_name: string;
    skill_level: string;
    availability_status: string;
  };
  role: "top" | "jungle" | "mid" | "adc" | "support" | "fill";
  is_starter: boolean;
  joined_at: string;
  position_notes?: string;
}

interface TeamTournament {
  id: string;
  tournament: {
    id: string;
    name: string;
    start_date: string;
    platform: string;
  };
  registration_status: string;
  registered_at: string;
  placement?: number;
}
```

**Error Responses**:

- 403: Forbidden (team captains can only access their own team)
- 404: Team not found

## PUT /api/teams/:teamId

**Purpose**: Update team information

**Request**:

```typescript
interface UpdateTeamRequest {
  name?: string;
  captain_id?: string;
  division?: string;
  description?: string;
  status?: "active" | "inactive" | "disbanded";
}
```

**Response** (200 OK):

```typescript
interface UpdateTeamResponse {
  team: Team;
  message: string;
}
```

**Error Responses**:

- 400: Validation errors
- 403: Forbidden (team captains can only update their own team)
- 404: Team not found

## POST /api/teams/:teamId/roster

**Purpose**: Add player to team roster

**Request**:

```typescript
interface AddRosterMemberRequest {
  player_id: string;
  role: "top" | "jungle" | "mid" | "adc" | "support" | "fill";
  is_starter: boolean;
  position_notes?: string;
}
```

**Response** (201 Created):

```typescript
interface AddRosterMemberResponse {
  roster_member: RosterMember;
  message: string;
}
```

**Error Responses**:

- 400: Validation errors
- 403: Forbidden
- 422: Business logic violations (roster full, player already on team, starter position taken)

## DELETE /api/teams/:teamId/roster/:playerId

**Purpose**: Remove player from team roster

**Response** (200 OK):

```typescript
interface RemoveRosterMemberResponse {
  message: string;
  removed_player: {
    id: string;
    summoner_name: string;
  };
}
```

**Error Responses**:

- 403: Forbidden
- 404: Player not found on roster
- 422: Cannot remove (player in active tournament)
