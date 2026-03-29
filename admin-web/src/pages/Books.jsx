import { useEffect, useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { getBooks, getPendingBooks, approveBook, setBookActive, deleteBook } from '../api'
import StatusBadge from '../components/StatusBadge'
import { IconEye, IconEdit, IconTrash, IconPause, IconPlay } from '../components/Icons'

export default function Books() {
  const [searchParams] = useSearchParams()
  const defaultTab = searchParams.get('tab') || 'all'
  const [tab, setTab] = useState(defaultTab)
  const [books, setBooks] = useState([])
  const [loading, setLoading] = useState(true)
  const [actionId, setActionId] = useState(null)
  const [toggleId, setToggleId] = useState(null)
  const [deleteId, setDeleteId] = useState(null)

  useEffect(() => { loadBooks() }, [tab])

  async function loadBooks() {
    setLoading(true)
    try {
      if (tab === 'pending') {
        const res = await getPendingBooks()
        setBooks(res.books || [])
      } else {
        const res = await getBooks()
        setBooks(res.books || [])
      }
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  async function handleApprove(book_id, status) {
    setActionId(book_id)
    try {
      await approveBook(book_id, status)
      await loadBooks()
    } catch (err) {
      alert(err.message)
    } finally {
      setActionId(null)
    }
  }

  async function handleToggleActive(book) {
    const currentStatus = book.submission_status || book.status || 'published'
    const makeActive = currentStatus === 'inactive'
    setToggleId(book.book_id)
    try {
      await setBookActive(book.book_id, makeActive)
      await loadBooks()
    } catch (err) {
      alert(err.message)
    } finally {
      setToggleId(null)
    }
  }

  async function handleDelete(book_id) {
    if (!window.confirm('Permanently delete this book and all its chapters?')) return
    setDeleteId(book_id)
    try {
      await deleteBook(book_id)
      await loadBooks()
    } catch (err) {
      alert(err.message)
    } finally {
      setDeleteId(null)
    }
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-bold text-gray-900">Books</h2>
        <Link to="/books/new"
          className="bg-pink-600 text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-pink-700 transition">
          + Add Book
        </Link>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 mb-6 bg-gray-100 p-1 rounded-lg w-fit">
        {['all', 'pending'].map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-4 py-1.5 rounded-md text-sm font-medium transition ${
              tab === t ? 'bg-white shadow text-gray-900' : 'text-gray-500 hover:text-gray-700'
            }`}>
            {t === 'all' ? 'All Books' : 'Pending Approval'}
          </button>
        ))}
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-40">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-pink-500" />
        </div>
      ) : books.length === 0 ? (
        <div className="text-center py-16 text-gray-400">No books found.</div>
      ) : (
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50 text-left">
                <th className="px-4 py-3 font-medium text-gray-600">Title</th>
                <th className="px-4 py-3 font-medium text-gray-600">Author</th>
                <th className="px-4 py-3 font-medium text-gray-600">Genre</th>
                <th className="px-4 py-3 font-medium text-gray-600">Status</th>
                <th className="px-4 py-3 font-medium text-gray-600">Actions</th>
              </tr>
            </thead>
            <tbody>
              {books.map((book) => {
                const bookStatus = book.submission_status || book.status || 'published'
                const isInactive = bookStatus === 'inactive'
                return (
                  <tr key={book.book_id} className="border-b border-gray-50 hover:bg-gray-50 transition">
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-3">
                        {book.cover_image && (
                          <img src={book.cover_image} alt="" className="w-8 h-10 object-cover rounded" />
                        )}
                        <span className="font-medium text-gray-900">{book.book_name}</span>
                      </div>
                    </td>
                    <td className="px-4 py-3 text-gray-600">{book.author_name}</td>
                    <td className="px-4 py-3 text-gray-600">
                      {Array.isArray(book.genre) ? book.genre.join(', ') : (book.genre || '—')}
                    </td>
                    <td className="px-4 py-3">
                      <StatusBadge status={bookStatus} />
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-1">
                        {/* View */}
                        <Link to={`/books/${book.book_id}`}
                          title="View"
                          className="p-1.5 text-gray-400 hover:text-pink-600 hover:bg-pink-50 rounded transition">
                          <IconEye />
                        </Link>
                        {/* Edit */}
                        <Link to={`/books/${book.book_id}/edit`}
                          title="Edit"
                          className="p-1.5 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded transition">
                          <IconEdit />
                        </Link>
                        {/* Delete */}
                        <button
                          onClick={() => handleDelete(book.book_id)}
                          disabled={deleteId === book.book_id}
                          title="Delete"
                          className="p-1.5 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded transition disabled:opacity-40">
                          <IconTrash />
                        </button>
                        {/* Deactivate / Activate */}
                        {bookStatus !== 'pending' && (
                          <button
                            onClick={() => handleToggleActive(book)}
                            disabled={toggleId === book.book_id}
                            title={isInactive ? 'Activate' : 'Deactivate'}
                            className={`p-1.5 rounded transition disabled:opacity-40 ${
                              isInactive
                                ? 'text-green-600 hover:bg-green-50'
                                : 'text-gray-400 hover:text-orange-500 hover:bg-orange-50'
                            }`}>
                            {isInactive ? <IconPlay /> : <IconPause />}
                          </button>
                        )}
                        {/* Approve / Reject for pending */}
                        {tab === 'pending' && (
                          <>
                            <button onClick={() => handleApprove(book.book_id, true)}
                              disabled={actionId === book.book_id}
                              className="text-green-600 hover:underline text-xs disabled:opacity-50 px-1">
                              Approve
                            </button>
                            <button onClick={() => handleApprove(book.book_id, false)}
                              disabled={actionId === book.book_id}
                              className="text-red-500 hover:underline text-xs disabled:opacity-50 px-1">
                              Reject
                            </button>
                          </>
                        )}
                      </div>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
