# Quickstart Guide: LoL Team Management Dashboard

## Development Setup

### Prerequisites

- Node.js 18+ and npm/yarn
- Git
- Modern web browser (Chrome, Firefox, Safari, Edge)

### Initial Setup

```bash
# Clone and setup project
git checkout 001-build-an-application

# Install backend dependencies
cd backend
npm install

# Install frontend dependencies
cd ../frontend
npm install

# Return to root
cd ..
```

### Database Setup

```bash
# Start PostgreSQL database with Docker
docker-compose up -d postgres

# Run database migrations
cd backend
npm run db:migrate

# Seed with sample data
npm run db:seed

# Reset database (development only)
npm run db:reset
```

### Development Servers

```bash
# Start backend API server (Terminal 1)
cd backend
npm run dev

# Start frontend development server (Terminal 2)
cd frontend
npm run dev

# Access application at http://localhost:5173
# API endpoints available at http://localhost:3000/api
```

## User Journey Validation

### Story 1: Team Manager Dashboard Overview

**Goal**: View all teams with status and upcoming tournaments

**Steps**:

1. Open http://localhost:5173
2. Login as team manager (demo@example.com / password)
3. Verify dashboard shows up to 10 teams
4. Check each team displays:
   - Team name and division
   - Roster count (e.g., "7/10 players")
   - Starter count (e.g., "5/5 starters")
   - Upcoming tournaments count
   - Status (Active/Inactive/Disbanded)

**Expected Result**: Clear overview of all team statuses and key metrics

### Story 2: Team Captain Roster Management

**Goal**: Team captain manages their team's roster

**Steps**:

1. Login as team captain (captain1@example.com / password)
2. Navigate to "My Team" page
3. View current roster with roles (Top, Jungle, Mid, ADC, Support)
4. Add new player from pipeline:
   - Click "Add Player" button
   - Search/filter available players
   - Select player and assign role
   - Mark as starter/substitute
   - Save changes
5. Remove player from roster:
   - Click remove button on roster member
   - Confirm removal
   - Verify player returns to pipeline

**Expected Result**: Team captain can fully manage their team roster

### Story 3: Player Pipeline Management

**Goal**: Manage interested players and filter by criteria

**Steps**:

1. Login as team manager
2. Navigate to "Player Pipeline" page
3. View all unassigned players
4. Test filters:
   - Filter by role (Top, Jungle, Mid, ADC, Support)
   - Filter by skill level (Iron through Challenger)
   - Filter by availability (Available, Busy, Unavailable)
   - Search by summoner name
5. Add new player:
   - Click "Add Player" button
   - Fill form with player details
   - Set preferred roles and proficiency
   - Save player to pipeline
6. Move player to team:
   - Drag player card to team roster slot
   - OR click "Assign to Team" and select team/role

**Expected Result**: Efficient player pipeline management with search and filtering

### Story 4: Tournament Registration

**Goal**: Register teams for tournaments and track status

**Steps**:

1. Login as team manager
2. Navigate to "Tournaments" page
3. View available tournaments with:
   - Tournament name and platform
   - Registration deadline
   - Entry fee and prize pool
   - Registration status
4. Register team for tournament:
   - Click "Register Team" on tournament
   - Select team to register
   - Verify roster completeness (5 starters minimum)
   - Confirm registration
5. View registered tournaments:
   - Check "My Tournaments" tab
   - Verify registration status
   - View roster snapshot taken at registration

**Expected Result**: Teams successfully registered for tournaments

### Story 5: Drag-and-Drop Player Assignment

**Goal**: Move players between pipeline and teams using drag-drop

**Steps**:

1. Login as team manager
2. Open dashboard with teams and player pipeline visible
3. Drag player from pipeline to team roster slot:
   - Grab player card from pipeline
   - Drag to empty roster position
   - Drop to assign player to role
   - Verify player shows in team roster
4. Drag player between teams:
   - Grab player from one team's roster
   - Drag to another team's roster slot
   - Drop to transfer player
   - Verify player moved between teams

**Expected Result**: Intuitive drag-drop interface for player management

## Performance Validation

### Performance Tests

```bash
# Frontend performance tests
cd frontend
npm run test:lighthouse
npm run analyze

# Backend API performance tests
cd backend
npm run test:load
npm run test:db-performance

# End-to-end performance tests
npm run test:e2e-performance
```

**Expected Metrics**:

- Frontend initial page load: < 2 seconds
- REST API responses: < 200ms (95th percentile)
- Frontend bundle size: < 500KB gzipped
- Database query performance: < 50ms average
- Lighthouse score: > 90

### Accessibility Tests

```bash
# Automated a11y testing
npm run test:a11y

# Screen reader testing
npm run test:screen-reader
```

**Expected Results**:

- WCAG 2.1 AA compliance
- Full keyboard navigation
- Screen reader compatibility
- High contrast mode support

## Error Scenarios

### Network Failures

1. Disconnect internet during tournament sync
2. Verify graceful degradation
3. Check error messages are user-friendly
4. Confirm offline functionality works

### Data Validation

1. Try to add player with duplicate summoner name
2. Attempt to exceed team roster limit
3. Register team with incomplete roster
4. Verify validation messages are clear

### Permission Boundaries

1. Login as team captain
2. Try to access other teams' rosters
3. Attempt to create new teams
4. Verify appropriate permission errors

## Production Deployment

### Build Verification

```bash
# Build frontend
cd frontend
npm run build

# Build backend
cd ../backend
npm run build

# Start production containers
cd ..
docker-compose -f docker-compose.prod.yml up -d
```

### Database Migration

```bash
# Run database migrations
docker-compose exec backend npm run db:migrate

# Seed production data (if needed)
docker-compose exec backend npm run db:seed

# Verify database health
docker-compose exec postgres pg_isready -U lol_dashboard
```

## Troubleshooting

### Common Issues

- **Database connection failed**: Check PostgreSQL container status with `docker-compose ps`
- **Port conflicts**: Frontend (3000), Backend (3001), Database (5432) - modify docker-compose.yml if needed
- **TypeScript errors**: Run `npm run type-check` in frontend and backend directories
- **Container build failures**: Clear Docker cache with `docker-compose down --volumes` and rebuild

### Debug Mode

```bash
# View container logs
docker-compose logs -f frontend
docker-compose logs -f backend
docker-compose logs -f postgres

# Enable debug logging
docker-compose -f docker-compose.yml -f docker-compose.debug.yml up

# Verbose test output
npm run test -- --verbose
```

### Data Reset

```bash
# Reset database and restart services
docker-compose down --volumes
docker-compose up -d postgres
docker-compose exec backend npm run db:migrate
docker-compose exec backend npm run db:seed
docker-compose up -d

# Clear browser storage if needed
# In DevTools: Application > Storage > Clear storage
```

```

```
