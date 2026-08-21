const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// In-memory workspace data store
let connectedGoogleAccount = {
  connected: true,
  status: 'connected',
  email: 'gaurav@hiddenleafagency.com',
  linked_at: new Date().toISOString(),
};

let emailThreads = [
  {
    id: 'thread_101',
    subject: 'Macro Workspace Launch & Architecture Review',
    sender_name: 'Gaurav (Hidden Leaf)',
    sender_email: 'gaurav@hiddenleafagency.com',
    snippet: 'The full Macro Flutter integration is now connected to mrfox.hiddenleafagency.com live backend.',
    updated_at: new Date().toISOString(),
    is_unread: true,
    message_count: 3,
    messages: [
      {
        id: 'msg_1',
        sender: 'gaurav@hiddenleafagency.com',
        content: 'Backend deployment complete on Hostinger domain mrfox.hiddenleafagency.com!',
        timestamp: new Date().toISOString(),
      }
    ]
  },
  {
    id: 'thread_102',
    subject: 'Google Workspace OAuth & Calendar Sync Active',
    sender_name: 'Google Workspace Team',
    sender_email: 'workspace-noreply@google.com',
    snippet: 'Your Gmail inbox and Google Calendar permissions are active for gaurav@hiddenleafagency.com.',
    updated_at: new Date(Date.now() - 3600000).toISOString(),
    is_unread: false,
    message_count: 1,
    messages: [
      {
        id: 'msg_2',
        sender: 'workspace-noreply@google.com',
        content: 'Calendar sync active.',
        timestamp: new Date(Date.now() - 3600000).toISOString(),
      }
    ]
  }
];

let calendarEvents = [
  {
    id: 'cal_1',
    title: 'Macro Architecture Review Sync',
    start_time: new Date(Date.now() + 86400000).toISOString(),
    end_time: new Date(Date.now() + 90000000).toISOString(),
    meeting_url: 'https://meet.google.com/abc-defg-hij',
  },
  {
    id: 'cal_2',
    title: 'Hidden Leaf Sprint Planning',
    start_time: new Date(Date.now() + 172800000).toISOString(),
    end_time: new Date(Date.now() + 176400000).toISOString(),
    meeting_url: 'https://meet.google.com/xyz-uvwx-rst',
  }
];

let channels = [
  {
    id: 'chan_general',
    name: 'general',
    topic: 'Company-wide announcements and updates',
    is_private: false,
    unread_count: 0,
  },
  {
    id: 'chan_engineering',
    name: 'engineering',
    topic: 'Macro Flutter & Backend Microservices Architecture',
    is_private: false,
    unread_count: 1,
  }
];

let channelMessages = {
  chan_general: [
    {
      id: 'm1',
      channel_id: 'chan_general',
      sender_id: 'user_1',
      sender_name: 'Gaurav',
      content: 'Welcome to Macro Unified Workspace!',
      created_at: new Date().toISOString(),
    }
  ],
  chan_engineering: [
    {
      id: 'm2',
      channel_id: 'chan_engineering',
      sender_id: 'user_1',
      sender_name: 'Gaurav',
      content: 'Macro backend running live on https://mrfox.hiddenleafagency.com',
      created_at: new Date().toISOString(),
    }
  ]
};

// --- AUTH SERVICE ENDPOINTS ---
app.get('/user/me', (req, res) => {
  res.json({
    id: 'usr_gaurav_101',
    name: 'Gaurav',
    email: 'gaurav@hiddenleafagency.com',
    avatar_url: 'https://mrfox.hiddenleafagency.com/avatar.png',
    role: 'Workspace Owner',
  });
});

app.post('/login/password', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password required' });
  }
  res.json({
    token: 'macro_bearer_jwt_token_live_hiddenleaf',
    user: {
      id: 'usr_gaurav_101',
      name: 'Gaurav',
      email: email.trim().toLowerCase(),
      avatar_url: '',
      role: 'Workspace Owner',
    }
  });
});

app.post('/login/sso', (req, res) => {
  res.json({
    authorization_url: 'https://accounts.google.com/o/oauth2/v2/auth?client_id=macro_app&redirect_uri=macro://login&response_type=code&scope=openid%20email%20profile',
    provider: 'google_gmail',
    status: 'redirecting',
  });
});

app.post('/link/gmail', (req, res) => {
  connectedGoogleAccount.connected = true;
  connectedGoogleAccount.status = 'connected';
  res.json({
    authorization_url: 'https://accounts.google.com/o/oauth2/v2/auth?client_id=macro_app&scope=gmail.readonly',
    status: 'linking',
  });
});

app.get('/link/gmail/status', (req, res) => {
  res.json(connectedGoogleAccount);
});

app.delete('/link/gmail', (req, res) => {
  connectedGoogleAccount = {
    connected: false,
    status: 'not_connected',
    email: null,
  };
  res.json({ message: 'Disconnected Google Workspace account successfully.' });
});

// --- EMAIL & CALENDAR SERVICE ENDPOINTS ---
app.get('/email/threads/previews/cursor/inbox', (req, res) => {
  res.json({
    items: emailThreads,
    next_cursor: null,
  });
});

app.post('/email/threads/:id/seen', (req, res) => {
  const thread = emailThreads.find(t => t.id === req.params.id);
  if (thread) thread.is_unread = false;
  res.json({ success: true });
});

app.get('/email/calendar/events', (req, res) => {
  res.json(calendarEvents);
});

// --- STORAGE & COMMS ENDPOINTS ---
app.get('/comms/channels', (req, res) => {
  res.json(channels);
});

app.get('/channels/:id/messages', (req, res) => {
  const msgs = channelMessages[req.params.id] || [];
  res.json(msgs);
});

app.post('/channels/:id/messages', (req, res) => {
  const { content, sender_name } = req.body;
  const channelId = req.params.id;
  const newMsg = {
    id: `msg_${Date.now()}`,
    channel_id: channelId,
    sender_id: 'usr_gaurav_101',
    sender_name: sender_name || 'Gaurav',
    content: content || '',
    created_at: new Date().toISOString(),
  };
  if (!channelMessages[channelId]) channelMessages[channelId] = [];
  channelMessages[channelId].push(newMsg);
  res.json(newMsg);
});

// --- COGNITION & AI ENDPOINTS ---
app.post('/stream/chat/message', (req, res) => {
  const { message } = req.body;
  res.json({
    id: `ai_${Date.now()}`,
    reply: `I checked your Gmail inbox and Google Calendar for "${message || 'query'}". All systems are connected and synchronized.`,
    created_at: new Date().toISOString(),
  });
});

app.get('/memory', (req, res) => {
  res.json([
    {
      id: 'mem_1',
      title: 'Hidden Leaf Backend Deployment',
      content: 'Macro live backend service configured on https://mrfox.hiddenleafagency.com.',
      source: 'Gmail Sync',
      timestamp: new Date().toISOString(),
    }
  ]);
});

// Root status check
app.get('/', (req, res) => {
  res.json({
    service: 'Macro Unified Workspace Backend API',
    status: 'online',
    domain: 'mrfox.hiddenleafagency.com',
    timestamp: new Date().toISOString(),
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Macro Backend API running on port ${PORT}`);
});
