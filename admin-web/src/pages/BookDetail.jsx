import { useEffect, useState } from 'react'
import { useParams, Link, useNavigate } from 'react-router-dom'
import { getBooks, getBookChapters, approveBook, updateChapter, deleteChapter, setBookActive, reprocessBookChapters } from '../api'
import StatusBadge from '../components/StatusBadge'
import FileUpload from '../components/FileUpload'
import { useAuth } from '../context/AuthContext'
import { IconEye, IconEdit, IconTrash } from '../components/Icons'
import { CHAPTER_ACCEPT } from '../constants'

// Format timer seconds → "30min" / "1h" / "1.5h"
function fmtTimer(secs) {
  if (!secs || Number(secs) === 0) return null
  const mins = Math.round(Number(secs) / 60)
  if (mins < 60) return `${mins}min`
  const hrs = mins / 60
  return `${Number.isInteger(hrs) ? hrs : hrs.toFixed(1)}h`
}

export default function BookDetail() {
  const { id } = useParams()
  const { role } = useAuth()
  const navigate = useNavigate()

  const [book, setBook] = useState(null)
  const [chapters, setChapters] = useState([])
  const [loading, setLoading] = useState(true)
  const [approving, setApproving] = useState(false)
  const [toggling, setToggling] = useState(false)
  const [editingChapter, setEditingChapter] = useState(null) // { chapter_number, ... }
  const [chSaving, setChSaving] = useState(false)
  const [deletingCh, setDeletingCh] = useState(null)
  const [reprocessing, setReprocessing] = useState(false)
  const [reprocessResult, setReprocessResult] = useState(null)

  useEffect(() => { loadData() }, [id])

  async function loadData() {
    try {
      const [booksRes, chapRes] = await Promise.all([
        getBooks(),
        getBookChapters(id),
      ])
      const found = (booksRes.books || []).find((b) => b.book_id === id)
      setBook(found || null)
      setChapters(chapRes.chapters || [])
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

  async function handleToggleActive() {
    const currentStatus = book.submission_status || book.status || 'published'
    const makeActive = currentStatus === 'inactive'
    setToggling(true)
    try {
      await setBookActive(id, makeActive)
      await loadData()
    } catch (err) {
      alert(err.message)
    } finally {
      setToggling(false)
    }
  }

  async function handleSaveChapter() {
    if (!editingChapter) return
    setChSaving(true)
    try {
      await updateChapter({
        book_id:          id,
        chapter_number:   editingChapter.chapter_number,
        chapter_title:    editingChapter.chapter_title,
        price_to_unlock:  Number(editingChapter.price_to_unlock),
        // convert minutes back to seconds
        timer_seconds:    Number(editingChapter.timer_min || 0) * 60,
        reward_ads_count: Number(editingChapter.reward_ads_count),
        ...(editingChapter.new_content_url ? { content_url: editingChapter.new_content_url } : {}),
      })
      setEditingChapter(null)
      await loadData()
    } catch (err) {
      alert(err.message)
    } finally {
      setChSaving(false)
    }
  }

  async function handleReprocess() {
    if (!window.confirm('Re-extract text from all .docx chapters? This may take a while.')) return
    setReprocessing(true)
    setReprocessResult(null)
    try {
      const res = await reprocessBookChapters(id)
      setReprocessResult(`✓ Done: ${res.updated} updated, ${res.skipped} skipped${res.errors ? `, ${res.errors} errors` : ''}`)
      await loadData()
    } catch (err) {
      setReprocessResult(`✗ Error: ${err.message}`)
    } finally {
      setReprocessing(false)
    }
  }

  async function handleDeleteChapter(ch) {
    if (!window.confirm(`Delete Chapter ${Number(ch.chapter_number)}: "${ch.chapter_title}"?`)) return
    setDeletingCh(ch.chapter_number)
    try {
      await deleteChapter(id, Number(ch.chapter_number))
      await loadData()
    } catch (err) {
      alert(err.message)
    } finally {
      setDeletingCh(null)
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

  const bookStatus = book.submission_status || book.status || 'published'
  const isInactive = bookStatus === 'inactive'

  return (
    <div className="space-y-6">
      {/* Top nav */}
      {role === 'admin' && (
        <div className="flex items-center">
          <Link to="/books" className="text-sm text-gray-400 hover:text-gray-600">← All Books</Link>
        </div>
      )}

      {/* Header */}
      <div className="flex items-start justify-between">
        <div className="flex gap-4">
          {book.cover_image && (
            <img src={book.cover_image} alt="cover" className="w-20 h-28 object-cover rounded-lg shadow" />
          )}
          <div>
            <h2 className="text-2xl font-bold text-gray-900">{book.book_name}</h2>
            <p className="text-gray-500 mt-1">by {book.author_name}</p>
            <div className="flex items-center gap-2 mt-2 flex-wrap">
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

        {role === 'admin' && (
          <div className="flex flex-col gap-2 items-end">
            {bookStatus === 'pending' && (
              <div className="flex gap-2">
                <button onClick={() => handleApprove(true)} disabled={approving}
                  className="bg-green-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-green-700 disabled:opacity-50 transition">
                  Approve & Publish
                </button>
                <button onClick={() => handleApprove(false)} disabled={approving}
                  className="bg-red-500 text-white px-4 py-2 rounded-lg text-sm hover:bg-red-600 disabled:opacity-50 transition">
                  Reject
                </button>
              </div>
            )}
            {bookStatus !== 'pending' && (
              <div className="flex gap-2">
                <button onClick={() => navigate(`/books/${id}/edit`)}
                  className="bg-white border border-pink-300 text-pink-600 px-4 py-2 rounded-lg text-sm font-medium hover:bg-pink-50 transition">
                  ✏️ Edit
                </button>
                <button onClick={handleToggleActive} disabled={toggling}
                  className={`px-4 py-2 rounded-lg text-sm font-medium transition disabled:opacity-50 ${
                    isInactive
                      ? 'bg-green-600 text-white hover:bg-green-700'
                      : 'border border-gray-300 text-gray-600 hover:bg-gray-50'
                  }`}>
                  {toggling ? '…' : isInactive ? '✓ Activate' : 'Deactivate'}
                </button>
              </div>
            )}
          </div>
        )}
      </div>

      {isInactive && (
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg px-4 py-3 text-sm text-yellow-800">
          ⚠️ This book is <strong>deactivated</strong> and is not visible in the mobile app.
        </div>
      )}

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
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-semibold text-gray-800">Chapters ({chapters.length})</h3>
          {role === 'admin' && chapters.length > 0 && (
            <div className="flex items-center gap-2">
              {reprocessResult && (
                <span className="text-xs text-gray-500">{reprocessResult}</span>
              )}
              <button
                onClick={handleReprocess}
                disabled={reprocessing}
                title="Re-extract text from .docx chapter files"
                className="text-xs border border-gray-300 text-gray-600 px-3 py-1.5 rounded-lg hover:bg-gray-50 disabled:opacity-50 transition">
                {reprocessing ? '⏳ Processing…' : '🔄 Reprocess text'}
              </button>
            </div>
          )}
        </div>
        {chapters.length === 0 ? (
          <p className="text-sm text-gray-400">No chapters attached to this book.</p>
        ) : (
          <div className="space-y-2">
            {chapters
              .slice()
              .sort((a, b) => Number(a.chapter_number) - Number(b.chapter_number))
              .map((ch) => {
                const chNum = Number(ch.chapter_number)
                const isEditing = editingChapter?.chapter_number === ch.chapter_number
                const isFree = !ch.price_to_unlock || Number(ch.price_to_unlock) === 0
                const timer = fmtTimer(ch.timer_seconds)

                return (
                  <div key={chNum} className="border border-gray-100 rounded-lg p-4">
                    {isEditing ? (
                      /* ── Edit mode ── */
                      <div className="space-y-3">
                        <div className="grid grid-cols-2 gap-3">
                          <div>
                            <label className="text-xs text-gray-500">Title</label>
                            <input value={editingChapter.chapter_title}
                              onChange={(e) => setEditingChapter((p) => ({ ...p, chapter_title: e.target.value }))}
                              className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm mt-1" />
                          </div>
                          <div>
                            <label className="text-xs text-gray-500">Replace file</label>
                            <div className="mt-1">
                              <FileUpload folder="chapters" accept={CHAPTER_ACCEPT}
                                label="Upload new file"
                                onUploaded={({ s3_url }) => setEditingChapter((p) => ({ ...p, new_content_url: s3_url }))} />
                            </div>
                            {editingChapter.new_content_url && (
                              <p className="text-xs text-green-600 mt-1">✓ New file ready</p>
                            )}
                          </div>
                        </div>
                        <div className="grid grid-cols-3 gap-3">
                          <div>
                            <label className="text-xs text-gray-500">Coins (price)</label>
                            <input type="number" min="0"
                              value={editingChapter.price_to_unlock}
                              onChange={(e) => setEditingChapter((p) => ({ ...p, price_to_unlock: e.target.value }))}
                              className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm mt-1" />
                          </div>
                          <div>
                            <label className="text-xs text-gray-500">Timer (minutes)</label>
                            <input type="number" min="0"
                              value={editingChapter.timer_min}
                              onChange={(e) => setEditingChapter((p) => ({ ...p, timer_min: e.target.value }))}
                              className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm mt-1" />
                          </div>
                          <div>
                            <label className="text-xs text-gray-500">Ads count</label>
                            <input type="number" min="0"
                              value={editingChapter.reward_ads_count}
                              onChange={(e) => setEditingChapter((p) => ({ ...p, reward_ads_count: e.target.value }))}
                              className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm mt-1" />
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
                      /* ── View mode ── */
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <div>
                            <span className="text-sm font-medium text-gray-800">
                              {chNum}. {ch.chapter_title}
                            </span>
                            <div className="flex gap-3 mt-0.5 text-xs text-gray-500">
                              {isFree ? (
                                <span className="text-green-600 font-medium">Free</span>
                              ) : (
                                <>
                                  <span>💰 {ch.price_to_unlock} coins</span>
                                  {timer && <span>⏱ {timer}</span>}
                                  {ch.reward_ads_count > 0 && <span>📺 {ch.reward_ads_count} ads</span>}
                                </>
                              )}
                              {ch.reads > 0 && <span>👁 {ch.reads}</span>}
                            </div>
                          </div>
                        </div>
                        {role === 'admin' && (
                          <div className="flex items-center gap-1">
                            {/* View content */}
                            {ch.content_url && (
                              <a href={ch.content_url} target="_blank" rel="noreferrer"
                                title="View content"
                                className="p-1.5 text-gray-400 hover:text-pink-600 hover:bg-pink-50 rounded transition">
                                <IconEye />
                              </a>
                            )}
                            {/* Edit */}
                            <button
                              onClick={() => setEditingChapter({
                                ...ch,
                                timer_min: Math.round(Number(ch.timer_seconds || 0) / 60),
                              })}
                              title="Edit"
                              className="p-1.5 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded transition">
                              <IconEdit />
                            </button>
                            {/* Delete */}
                            <button
                              onClick={() => handleDeleteChapter(ch)}
                              disabled={deletingCh === ch.chapter_number}
                              title="Delete"
                              className="p-1.5 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded transition disabled:opacity-40">
                              <IconTrash />
                            </button>
                          </div>
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
          <Link to={`/writers/${book.writer_id}`} className="text-pink-600 hover:underline text-sm">
            {book.writer_name || book.writer_id} — View profile & contracts →
          </Link>
        </div>
      )}
    </div>
  )
}
