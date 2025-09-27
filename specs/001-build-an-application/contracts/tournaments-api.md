# Tournament Integration API Contract

## GET /api/tournaments

**Purpose**: Get available tournaments for team registration

**Request**:

```typescript
interface GetTournamentsQuery {
  status?:
    | "upcoming"
    | "registration_open"
    | "registration_closed"
    | "in_progress"
    | "completed";
  platform?: "riot_games" | "battlefy" | "toornament" | "challonge" | "custom";
  team_id?: string; // filter by team's registered tournaments
  limit?: number; // default: 20, max: 50
  offset?: number; // default: 0
}
```

**Response** (200 OK):

```typescript
interface GetTournamentsResponse {
  tournaments: Tournament[];
  total: number;
  hasMore: boolean;
}

interface Tournament {
  id: string;
  external_id?: string;
  name: string;
  platform: string;
  start_date: string;
  end_date: string;
  registration_deadline: string;
  max_teams?: number;
  entry_fee?: number;
  prize_pool?: number;
  rules_url?: string;
  status: string;
  sync_status: "synced" | "pending" | "error" | "manual";
  registered_teams_count: number;
  user_team_status?: "registered" | "waitlisted" | "confirmed" | null;
}
```

**Error Responses**:

- 400: Invalid query parameters
- 401: Unauthorized access

## POST /api/tournaments

**Purpose**: Create custom tournament (manual entry)

**Request**:

```typescript
interface CreateTournamentRequest {
  name: string;
  platform: "custom";
  start_date: string; // ISO date
  end_date: string; // ISO date
  registration_deadline: string; // ISO timestamp
  max_teams?: number;
  entry_fee?: number;
  prize_pool?: number;
  rules_url?: string;
}
```

**Response** (201 Created):

```typescript
interface CreateTournamentResponse {
  tournament: Tournament;
  message: string;
}
```

**Error Responses**:

- 400: Validation errors
- 401: Unauthorized (only team managers)
- 422: Business logic violations (invalid dates)

## POST /api/tournaments/:tournamentId/register

**Purpose**: Register team for tournament

**Request**:

```typescript
interface RegisterTeamRequest {
  team_id: string;
  roster_snapshot?: RosterMember[]; // auto-generated if not provided
}
```

**Response** (201 Created):

```typescript
interface RegisterTeamResponse {
  registration: TeamTournamentRegistration;
  message: string;
}

interface TeamTournamentRegistration {
  id: string;
  team: {
    id: string;
    name: string;
  };
  tournament: {
    id: string;
    name: string;
  };
  registration_status: "registered" | "waitlisted" | "confirmed";
  registered_at: string;
  roster_snapshot: RosterMember[];
}
```

**Error Responses**:

- 400: Validation errors
- 403: Forbidden (only team managers and team captains)
- 404: Tournament or team not found
- 422: Business logic violations (registration deadline passed, roster incomplete, already registered)

## DELETE /api/tournaments/:tournamentId/register/:teamId

**Purpose**: Withdraw team from tournament

**Response** (200 OK):

```typescript
interface WithdrawTeamResponse {
  message: string;
  withdrawal: {
    team_name: string;
    tournament_name: string;
    withdrawn_at: string;
  };
}
```

**Error Responses**:

- 403: Forbidden
- 404: Registration not found
- 422: Cannot withdraw (tournament already started)

## POST /api/tournaments/sync

**Purpose**: Sync tournaments from external platforms

**Request**:

```typescript
interface SyncTournamentsRequest {
  platforms?: string[]; // specific platforms to sync, defaults to all
  force_refresh?: boolean; // ignore cache, defaults to false
}
```

**Response** (200 OK):

```typescript
interface SyncTournamentsResponse {
  synced_count: number;
  updated_count: number;
  error_count: number;
  sync_results: SyncResult[];
  message: string;
}

interface SyncResult {
  platform: string;
  status: "success" | "error" | "partial";
  tournaments_found: number;
  error_message?: string;
}
```

**Error Responses**:

- 401: Unauthorized (only team managers)
- 503: External API unavailable

## GET /api/tournaments/:tournamentId/teams

**Purpose**: Get teams registered for tournament

**Response** (200 OK):

```typescript
interface TournamentTeamsResponse {
  tournament: {
    id: string;
    name: string;
    max_teams?: number;
  };
  registered_teams: RegisteredTeam[];
  total_registered: number;
}

interface RegisteredTeam {
  team: {
    id: string;
    name: string;
    division: string;
  };
  registration_status: string;
  registered_at: string;
  roster_size: number;
  placement?: number;
}
```

**Error Responses**:

- 404: Tournament not found
