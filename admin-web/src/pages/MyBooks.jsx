import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import { getWriterBooks } from '../api'
import { useAuth } from '../context/AuthContext'
import StatusBadge from '../components/StatusBadge'

export default function MyBooks() {
  const { profile } = useAuth()
  const [books, setBooks] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (profile?.user_id) {
      getWriterBooks(profile.user_id)
        .then((res) => setBooks(res.books || []))
        .catch(console.error)
        .finally(() => setLoading(false))
    }
  }, [profile])

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-bold text-gray-900">My Books</h2>
        <Link
          to="/my-books/new"
          className="bg-pink-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-pink-700 transition"
        >
          + Submit Book
        </Link>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-40">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-pink-500" />
        </div>
      ) : books.length === 0 ? (
        <div className="text-center py-16 text-gray-400">
          <p>You haven't submitted any books yet.</p>
          <Link to="/my-books/new" className="text-pink-600 hover:underline text-sm mt-2 inline-block">
            Submit your first book →
          </Link>
        </div>
      ) : (
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50 text-left">
                <th className="px-4 py-3 font-medium text-gray-600">Title</th>
                <th className="px-4 py-3 font-medium text-gray-600">Category</th>
                <th className="px-4 py-3 font-medium text-gray-600">Status</th>
                <th className="px-4 py-3 font-medium text-gray-600">Chapters</th>
                <th className="px-4 py-3 font-medium text-gray-600">Actions</th>
              </tr>
            </thead>
            <tbody>
              {books.map((b) => (
                <tr key={b.book_id} className="border-b border-gray-50 hover:bg-gray-50">
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-3">
                      {b.cover_image && (
                        <img src={b.cover_image} alt="" className="w-8 h-10 object-cover rounded" />
                      )}
                      <span className="font-medium text-gray-900">{b.book_name}</span>
                    </div>
                  </td>
                  <td className="px-4 py-3 text-gray-600">
                    {Array.isArray(b.genre) ? b.genre.join(', ') : (b.genre || '—')}
                  </td>
                  <td className="px-4 py-3">
                    <StatusBadge status={b.status || 'pending'} />
                  </td>
                  <td className="px-4 py-3 text-gray-600">
                    {(b.chapters || []).length}
                  </td>
                  <td className="px-4 py-3">
                    <Link to={`/books/${b.book_id}`} className="text-xs text-pink-600 hover:underline">
                      View →
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
