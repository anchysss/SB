import { Link, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

const adminNav = [
  { to: '/', label: '📊 Dashboard' },
  { to: '/books', label: '📚 Books' },
  { to: '/writers', label: '✍️ Writers' },
  { to: '/earnings', label: '💰 Earnings' },
]

const writerNav = [
  { to: '/', label: '📊 Dashboard' },
  { to: '/my-books', label: '📚 My Books' },
  { to: '/my-earnings', label: '💰 My Earnings' },
]

export default function Layout({ children }) {
  const { role, user, profile, logout } = useAuth()
  const location = useLocation()
  const navigate = useNavigate()

  const nav = role === 'admin' ? adminNav : writerNav

  const handleLogout = async () => {
    await logout()
    navigate('/login')
  }

  return (
    <div className="flex min-h-screen">
      {/* Sidebar */}
      <aside className="w-56 bg-gray-900 text-white flex flex-col">
        <div className="px-6 py-5 border-b border-gray-700">
          <h1 className="text-lg font-bold text-pink-400">SteamyBook</h1>
          <p className="text-xs text-gray-400 mt-1 capitalize">{role} panel</p>
        </div>

        <nav className="flex-1 py-4">
          {nav.map((item) => (
            <Link
              key={item.to}
              to={item.to}
              className={`flex items-center px-6 py-3 text-sm transition-colors ${
                location.pathname === item.to
                  ? 'bg-pink-600 text-white'
                  : 'text-gray-300 hover:bg-gray-800'
              }`}
            >
              {item.label}
            </Link>
          ))}
        </nav>

        <div className="px-6 py-4 border-t border-gray-700">
          <p className="text-xs text-gray-400 truncate mb-2">
            {profile?.name || user?.email}
          </p>
          <button
            onClick={handleLogout}
            className="text-xs text-gray-400 hover:text-red-400 transition-colors"
          >
            Log out
          </button>
        </div>
      </aside>

      {/* Main content */}
      <main className="flex-1 overflow-auto bg-gray-50">
        <div className="max-w-6xl mx-auto p-8">{children}</div>
      </main>
    </div>
  )
}
