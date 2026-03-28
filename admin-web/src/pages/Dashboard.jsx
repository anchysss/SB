import { useEffect, useState } from 'react'
import { useAuth } from '../context/AuthContext'
import { getBooks, getPendingBooks, getWriters, getEarnings, getWriterBooks, getWriterEarnings } from '../api'
import { Link } from 'react-router-dom'
import StatusBadge from '../components/StatusBadge'

function StatCard({ title, value, color = 'pink' }) {
  const colors = {
    pink: 'border-pink-200 bg-pink-50 text-pink-700',
    blue: 'border-blue-200 bg-blue-50 text-blue-700',
    green: 'border-green-200 bg-green-50 text-green-700',
    yellow: 'border-yellow-200 bg-yellow-50 text-yellow-700',
  }
  return (
    <div className={`border rounded-xl p-5 ${colors[color]}`}>
      <p className="text-sm font-medium opacity-70">{title}</p>
      <p className="text-3xl font-bold mt-1">{value}</p>
    </div>
  )
}

export default function Dashboard() {
  const { role, profile } = useAuth()
  const [stats, setStats] = useState({})
  const [pending, setPending] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (role === 'admin') loadAdminStats()
    else if (role === 'writer' && profile) loadWriterStats()
  }, [role, profile])

  async function loadAdminStats() {
    try {
      const [booksRes, pendingRes, writersRes] = await Promise.all([
        getBooks(),
        getPendingBooks(),
        getWriters(),
      ])
      const books = booksRes.books || []
      const writers = writersRes.writers || []
      const pendingList = pendingRes.books || []
      setStats({
        books: books.length,
        writers: writers.length,
        pending: pendingList.length,
      })
      setPending(pendingList.slice(0, 5))
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  async function loadWriterStats() {
    try {
      const [booksRes, earningsRes] = await Promise.all([
        getWriterBooks(profile.user_id),
        getWriterEarnings(profile.user_id),
      ])
      const books = booksRes.books || []
      const earnings = earningsRes.earnings || []
      const totalEarned = earnings.reduce((s, e) => s + (parseFloat(e.total_payout) || parseFloat(e.amount) || 0), 0)
      setStats({
        books: books.length,
        earnings: totalEarned.toFixed(2),
        published: books.filter((b) => b.status === 'published').length,
        pending: books.filter((b) => b.status === 'pending').length,
      })
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-pink-500" />
      </div>
    )
  }

  return (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">
        {role === 'admin' ? 'Admin Dashboard' : `Welcome, ${profile?.name || 'Writer'}`}
      </h2>

      {role === 'admin' && (
        <>
          <div className="grid grid-cols-3 gap-4 mb-8">
            <StatCard title="Total Books" value={stats.books || 0} color="pink" />
            <StatCard title="Writers" value={stats.writers || 0} color="blue" />
            <StatCard title="Pending Approval" value={stats.pending || 0} color="yellow" />
          </div>

          {pending.length > 0 && (
            <div className="bg-white rounded-xl border border-gray-200 p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-gray-900">Pending Books</h3>
                <Link to="/books?tab=pending" className="text-sm text-pink-600 hover:underline">
                  View all →
                </Link>
              </div>
              <div className="space-y-3">
                {pending.map((book) => (
                  <div key={book.book_id} className="flex items-center justify-between py-2 border-b border-gray-100 last:border-0">
                    <div>
                      <p className="text-sm font-medium text-gray-900">{book.book_name}</p>
                      <p className="text-xs text-gray-500">{book.author_name}</p>
                    </div>
                    <div className="flex items-center gap-3">
                      <StatusBadge status={book.status} />
                      <Link to={`/books/${book.book_id}`} className="text-xs text-pink-600 hover:underline">
                        Review →
                      </Link>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </>
      )}

      {role === 'writer' && (
        <div className="grid grid-cols-2 gap-4">
          <StatCard title="Total Books" value={stats.books || 0} color="pink" />
          <StatCard title="Published" value={stats.published || 0} color="green" />
          <StatCard title="Pending Approval" value={stats.pending || 0} color="yellow" />
          <StatCard title="Total Earned ($)" value={stats.earnings || '0.00'} color="blue" />
        </div>
      )}
    </div>
  )
}
