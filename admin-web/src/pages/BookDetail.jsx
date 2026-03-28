import { useEffect, useState } from 'react'
import { useParams, Link } from 'react-router-dom'
import { getBooks, approveBook, updateChapter } from '../api'
import StatusBadge from '../components/StatusBadge'
import { useAuth } from '../context/AuthContext'

export default function BookDetail() {
  const { id } = useParams()
  const { role } = useAuth()

  const [book, setBook] = useState(null)
  const [chapters, setChapters] = useState([])
  const [loading, setLoading] = useState(true)
  const [approving, setApproving] = useState(false)
  const [editingChapter, setEditingChapter] = useState(null)
  const [chSaving, setChSaving] = useState(false)

  useEffect(() => {
    loadData()
  }, [id])

  async function loadData() {
    try {
      const booksRes = await getBooks()
      const found = (booksRes.books || []).find((b) => b.book_id === id)
      setBook(found || null)
      // Chapters may be embedded in book or need separate fetch
      setChapters(found?.chapters || [])
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  async function handleApprove(approved) {
    setApproving(true)
    try {
      await approveBook(id, approved)
      await loadData()
    } catch (err) {
      alert(err.message)
    } finally {
      setApproving(false)
    }
  }

  async function handleSaveChapter() {
    if (!editingChapter) return
    setChSaving(true)
    try {
      await updateChapter({
        book_id: id,
        chapter_number: editingChapter.chapter_number,
        chapter_title: editingChapter.chapter_title,
        price_to_unlock: Number(editingChapter.price_to_unlock),
        timer_seconds: Number(editingChapter.timer_seconds),
        reward_ads_count: Number(editingChapter.reward_ads_count),
      })
      setEditingChapter(null)
      await loadData()
    } catch (err) {
      alert(err.message)
    } finally {
      setChSaving(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-pink-500" />
      </div>
    )
  }

  if (!book) {
    return (
      <div className="text-center py-20 text-gray-400">
        Book not found.{' '}
        <Link to="/books" className="text-pink-600 hover:underline">Go back</Link>
      </div>
    )
  }

  // Determine display status from submission_status or book.status
  const bookStatus = book.submission_status || book.status || 'published'

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-start justify-between">
        <div className="flex gap-4">
          {book.cover_image && (
            <img src={book.cover_image} alt="cover" className="w-20 h-28 object-cover rounded-lg shadow" />
          )}
          <div>
            <h2 className="text-2xl font-bold text-gray-900">{book.book_name}</h2>
            <p className="text-gray-500 mt-1">by {book.author_name}</p>
            <div className="flex items-center gap-2 mt-2">
              <StatusBadge status={bookStatus} />
              {book.genre && (
                <span className="text-xs text-gray-500 border border-gray-200 px-2 py-0.5 rounded-full">
                  {Array.isArray(book.genre) ? book.genre.join(', ') : book.genre}
                </span>
              )}
            </div>
            {book.writer_name && (
              <p className="text-xs text-gray-400 mt-1">Writer: {book.writer_name}</p>
            )}
          </div>
        </div>

        {role === 'admin' && bookStatus === 'pending' && (
          <div className="flex gap-2">
            <button
              onClick={() => handleApprove(true)}
              disabled={approving}
              className="bg-green-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-green-700 disabled:opacity-50 transition"
            >
              Approve & Publish
            </button>
            <button
              onClick={() => handleApprove(false)}
              disabled={approving}
              className="bg-red-500 text-white px-4 py-2 rounded-lg text-sm hover:bg-red-600 disabled:opacity-50 transition"
            >
              Reject
            </button>
          </div>
        )}
      </div>

      {/* Description */}
      {book.short_summary && (
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <h3 className="font-semibold text-gray-800 mb-2">Description</h3>
          <p className="text-sm text-gray-600 leading-relaxed">{book.short_summary}</p>
        </div>
      )}

      {/* Tags */}
      {book.tags && book.tags.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {book.tags.map((tag, i) => (
            <span key={i} className="text-xs bg-pink-50 text-pink-600 border border-pink-100 px-2.5 py-1 rounded-full">
              #{tag}
            </span>
          ))}
        </div>
      )}

      {/* Stats */}
      <div className="grid grid-cols-4 gap-3">
        {[
          { label: 'Rating', value: book.rate || '—' },
          { label: 'Reads', value: book.total_reads || 0 },
          { label: 'Steamy votes', value: book.total_steamy_votes || 0 },
          { label: 'Ratings count', value: book.rating_count || 0 },
        ].map((s) => (
          <div key={s.label} className="bg-white border border-gray-200 rounded-lg p-3 text-center">
            <p className="text-xl font-bold text-gray-900">{s.value}</p>
            <p className="text-xs text-gray-500 mt-0.5">{s.label}</p>
          </div>
        ))}
      </div>

      {/* Chapters */}
      <div className="bg-white rounded-xl border border-gray-200 p-6">
        <h3 className="font-semibold text-gray-800 mb-4">Chapters ({chapters.length})</h3>
        {chapters.length === 0 ? (
          <p className="text-sm text-gray-400">No chapters attached to this book.</p>
        ) : (
          <div className="space-y-2">
            {chapters
              .slice()
              .sort((a, b) => Number(a.chapter_number) - Number(b.chapter_number))
              .map((ch) => {
                const isEditing = editingChapter?.chapter_number === ch.chapter_number
                const isFree = !ch.price_to_unlock || Number(ch.price_to_unlock) === 0
                return (
                  <div key={ch.chapter_number} className="border border-gray-100 rounded-lg p-4">
                    {isEditing ? (
                      <div>
                        <div className="grid grid-cols-2 gap-3 mb-3">
                          <div>
                            <label className="text-xs text-gray-500">Chapter Title</label>
                            <input
                              value={editingChapter.chapter_title}
                              onChange={(e) => setEditingChapter((p) => ({ ...p, chapter_title: e.target.value }))}
                              className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm mt-1"
                            />
                          </div>
                        </div>
                        <div className="grid grid-cols-3 gap-3 mb-3">
                          <div>
                            <label className="text-xs text-gray-500">Coins (price_to_unlock)</label>
                            <input type="number" min="0"
                              value={editingChapter.price_to_unlock}
                              onChange={(e) => setEditingChapter((p) => ({ ...p, price_to_unlock: e.target.value }))}
                              className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm mt-1"
                            />
                          </div>
                          <div>
                            <label className="text-xs text-gray-500">Timer (seconds)</label>
                            <input type="number" min="0"
                              value={editingChapter.timer_seconds}
                              onChange={(e) => setEditingChapter((p) => ({ ...p, timer_seconds: e.target.value }))}
                              className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm mt-1"
                            />
                          </div>
                          <div>
                            <label className="text-xs text-gray-500">Ads count</label>
                            <input type="number" min="0"
                              value={editingChapter.reward_ads_count}
                              onChange={(e) => setEditingChapter((p) => ({ ...p, reward_ads_count: e.target.value }))}
                              className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm mt-1"
                            />
                          </div>
                        </div>
                        <div className="flex gap-2">
                          <button onClick={handleSaveChapter} disabled={chSaving}
                            className="bg-pink-600 text-white px-4 py-1.5 rounded text-sm disabled:opacity-50">
                            {chSaving ? 'Saving…' : 'Save'}
                          </button>
                          <button onClick={() => setEditingChapter(null)}
                            className="border border-gray-300 text-gray-600 px-4 py-1.5 rounded text-sm">
                            Cancel
                          </button>
                        </div>
                      </div>
                    ) : (
                      <div className="flex items-center justify-between">
                        <div>
                          <span className="text-sm font-medium text-gray-800">
                            {Number(ch.chapter_number)}. {ch.chapter_title}
                          </span>
                          <div className="flex gap-3 mt-1 text-xs text-gray-500">
                            {isFree ? (
                              <span className="text-green-600 font-medium">Free</span>
                            ) : (
                              <>
                                <span>💰 {ch.price_to_unlock} coins</span>
                                {ch.timer_seconds > 0 && <span>⏱ {ch.timer_seconds}s</span>}
                                {ch.reward_ads_count > 0 && <span>📺 {ch.reward_ads_count} ads</span>}
                              </>
                            )}
                            {ch.reads > 0 && <span>👁 {ch.reads} reads</span>}
                            {ch.steamy_votes > 0 && <span>🔥 {ch.steamy_votes}</span>}
                          </div>
                        </div>
                        {role === 'admin' && (
                          <button onClick={() => setEditingChapter({ ...ch })}
                            className="text-xs text-pink-600 hover:underline">
                            Edit
                          </button>
                        )}
                      </div>
                    )}
                  </div>
                )
              })}
          </div>
        )}
      </div>

      {/* Writer link */}
      {book.writer_id && role === 'admin' && (
        <div className="bg-white rounded-xl border border-gray-200 p-5">
          <h3 className="font-semibold text-gray-800 mb-2">Writer</h3>
          <Link
            to={`/writers/${book.writer_id}`}
            className="text-pink-600 hover:underline text-sm"
          >
            {book.writer_name || book.writer_id} — View profile & contracts →
          </Link>
        </div>
      )}
    </div>
  )
}
