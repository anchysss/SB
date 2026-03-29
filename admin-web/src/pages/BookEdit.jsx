import { useEffect, useRef, useState } from 'react'
import { useNavigate, useParams, Link } from 'react-router-dom'
import { getBooks, getBookChapters, updateBook, updateChapter, addChapters, deleteChapter, uploadFile } from '../api'
import { GENRES, TAGS, CHAPTER_ACCEPT } from '../constants'
import FileUpload from '../components/FileUpload'
import { IconTrash } from '../components/Icons'

function CheckboxGroup({ options, selected, onChange, cols = 5 }) {
  const toggle = (val) =>
    onChange(selected.includes(val) ? selected.filter((v) => v !== val) : [...selected, val])
  return (
    <div className={`grid grid-cols-${cols} gap-2`}>
      {options.map((opt) => (
        <label key={opt} className="flex items-center gap-1.5 cursor-pointer text-sm text-gray-700 hover:text-pink-600">
          <input type="checkbox" checked={selected.includes(opt)} onChange={() => toggle(opt)} className="accent-pink-500" />
          {opt}
        </label>
      ))}
    </div>
  )
}

// Format seconds → minutes for display in input
const secToMin = (s) => Math.round(Number(s || 0) / 60)
// Format timer for display label
const fmtTimer = (secs) => {
  if (!secs || Number(secs) === 0) return null
  const mins = Math.round(Number(secs) / 60)
  if (mins < 60) return `${mins}min`
  const hrs = mins / 60
  return `${Number.isInteger(hrs) ? hrs : hrs.toFixed(1)}h`
}

export default function BookEdit() {
  const { id } = useParams()
  const navigate = useNavigate()

  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const [form, setForm] = useState({
    title: '', author: '', description: '', genres: [], tags: [], cover_url: '',
  })

  // Existing chapters – store timer_min (minutes) for input
  const [existingChapters, setExistingChapters] = useState([])
  const [modifiedChapters, setModifiedChapters] = useState({})
  const [deletingCh, setDeletingCh] = useState(null)

  // New chapters to append
  const [newChapters, setNewChapters] = useState([])

  // Bulk add
  const [bulkCount, setBulkCount] = useState('')
  const [bulkAdding, setBulkAdding] = useState(false)

  const set = (k, v) => setForm((f) => ({ ...f, [k]: v }))

  useEffect(() => {
    async function load() {
      try {
        const [booksRes, chapRes] = await Promise.all([getBooks(), getBookChapters(id)])
        const book = (booksRes.books || []).find((b) => b.book_id === id)
        if (book) {
          setForm({
            title:       book.book_name || '',
            author:      book.author_name || '',
            description: book.short_summary || '',
            genres:      Array.isArray(book.genre) ? book.genre : (book.genre ? [book.genre] : []),
            tags:        Array.isArray(book.tags) ? book.tags : [],
            cover_url:   book.cover_image || '',
          })
        }
        // Convert timer_seconds → timer_min for UI
        setExistingChapters(
          (chapRes.chapters || []).map((ch) => ({
            ...ch,
            timer_min: secToMin(ch.timer_seconds),
          }))
        )
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [id])

  // ── Existing chapter helpers ──────────────────────────────────────────────

  function updateExistingCh(chNum, key, val) {
    setExistingChapters((prev) =>
      prev.map((c) => (Number(c.chapter_number) === chNum ? { ...c, [key]: val } : c))
    )
    setModifiedChapters((prev) => ({ ...prev, [chNum]: true }))
  }

  async function handleDeleteExisting(ch) {
    const chNum = Number(ch.chapter_number)
    if (!window.confirm(`Delete Chapter ${chNum}: "${ch.chapter_title}"?`)) return
    setDeletingCh(chNum)
    try {
      await deleteChapter(id, chNum)
      setExistingChapters((prev) => prev.filter((c) => Number(c.chapter_number) !== chNum))
      setModifiedChapters((prev) => { const n = { ...prev }; delete n[chNum]; return n })
    } catch (err) {
      alert(err.message)
    } finally {
      setDeletingCh(null)
    }
  }

  // ── New chapter helpers ───────────────────────────────────────────────────

  const addNewChapter = () =>
    setNewChapters((prev) => [
      ...prev,
      {
        id: Date.now(),
        title: `Chapter ${existingChapters.length + prev.length + 1}`,
        content_url: '',
        price: 0, timer_min: 0, ads: 0, is_free: true,
      },
    ])

  const updateNewCh = (chId, key, val) =>
    setNewChapters((prev) => prev.map((c) => (c.id === chId ? { ...c, [key]: val } : c)))

  const removeNewCh = (chId) => setNewChapters((prev) => prev.filter((c) => c.id !== chId))

  // ── Bulk file upload ──────────────────────────────────────────────────────
  // Select multiple files → each becomes a chapter. First 10 free, rest paid.

  const bulkFileRef = useRef(null)

  async function handleBulkFileUpload(e) {
    const files = Array.from(e.target.files || [])
    if (!files.length) return
    setBulkAdding(true)
    const results = []
    for (let i = 0; i < files.length; i++) {
      const file = files[i]
      const globalNum = existingChapters.length + newChapters.length + results.length + 1
      const isFree = globalNum <= 10
      try {
        const { s3_url } = await uploadFile(file, 'chapters')
        results.push({
          id: Date.now() + i,
          title: `Chapter ${globalNum}`,
          content_url: s3_url,
          fileName: file.name,
          price: isFree ? 0 : 1,
          timer_min: isFree ? 0 : 60,
          ads: isFree ? 0 : 1,
          is_free: isFree,
        })
      } catch (err) {
        results.push({
          id: Date.now() + i,
          title: `Chapter ${globalNum}`,
          content_url: '',
          fileName: file.name,
          uploadError: err.message,
          price: isFree ? 0 : 1,
          timer_min: isFree ? 0 : 60,
          ads: isFree ? 0 : 1,
          is_free: isFree,
        })
      }
    }
    setNewChapters((prev) => [...prev, ...results])
    setBulkAdding(false)
    if (bulkFileRef.current) bulkFileRef.current.value = ''
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  async function handleSubmit(e) {
    e.preventDefault()
    if (!form.title.trim()) return setError('Title is required')
    setSaving(true)
    setError('')
    setSuccess('')
    try {
      // 1. Update book metadata
      await updateBook({
        book_id:         id,
        book_name:       form.title,
        author_name:     form.author,
        genre:           form.genres,
        tags:            form.tags,
        short_summary:   form.description,
        cover_image_url: form.cover_url || undefined,
      })

      // 2. Save modified existing chapters
      for (const chNum of Object.keys(modifiedChapters).map(Number)) {
        const ch = existingChapters.find((c) => Number(c.chapter_number) === chNum)
        if (!ch) continue
        await updateChapter({
          book_id:          id,
          chapter_number:   chNum,
          chapter_title:    ch.chapter_title,
          price_to_unlock:  Number(ch.price_to_unlock) || 0,
          timer_seconds:    Number(ch.timer_min || 0) * 60,
          reward_ads_count: Number(ch.reward_ads_count) || 0,
          ...(ch.new_content_url ? { content_url: ch.new_content_url } : {}),
        })
      }

      // 3. Add new chapters
      if (newChapters.length > 0) {
        await addChapters(id, newChapters.map((c) => ({
          chapter_title:    c.title,
          content_url:      c.content_url || '',
          price_to_unlock:  c.is_free ? 0 : Number(c.price) || 0,
          timer_seconds:    c.is_free ? 0 : Number(c.timer_min || 0) * 60,
          reward_ads_count: c.is_free ? 0 : Number(c.ads) || 0,
        })))
      }

      setSuccess('Saved!')
      setTimeout(() => navigate(`/books/${id}`), 900)
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-pink-500" />
      </div>
    )
  }

  return (
    <div>
      <div className="flex items-center gap-3 mb-6">
        <Link to={`/books/${id}`} className="text-gray-400 hover:text-gray-600 text-sm">← Back</Link>
        <h2 className="text-2xl font-bold text-gray-900">Edit Book</h2>
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">

        {/* ── Book metadata ── */}
        <div className="bg-white rounded-xl border border-gray-200 p-6 space-y-4">
          <h3 className="font-semibold text-gray-800">Book Information</h3>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Title *</label>
              <input value={form.title} onChange={(e) => set('title', e.target.value)}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-pink-400" />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Author</label>
              <input value={form.author} onChange={(e) => set('author', e.target.value)}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-pink-400" />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea value={form.description} onChange={(e) => set('description', e.target.value)}
              rows={4} className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-pink-400" />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Genres {form.genres.length > 0 && <span className="ml-1 text-pink-500 font-normal">({form.genres.join(', ')})</span>}
            </label>
            <div className="border border-gray-200 rounded-lg p-3 bg-gray-50">
              <CheckboxGroup options={GENRES} selected={form.genres} onChange={(v) => set('genres', v)} />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Tags {form.tags.length > 0 && <span className="ml-1 text-pink-500 font-normal">({form.tags.length} selected)</span>}
            </label>
            <div className="border border-gray-200 rounded-lg p-3 bg-gray-50">
              <CheckboxGroup options={TAGS} selected={form.tags} onChange={(v) => set('tags', v)} />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Cover Image</label>
            {form.cover_url && (
              <img src={form.cover_url} alt="cover" className="h-20 rounded object-cover mb-2" />
            )}
            <FileUpload folder="covers" accept="image/*" label="Replace Cover"
              onUploaded={({ s3_url }) => set('cover_url', s3_url)} />
          </div>
        </div>

        {/* ── Existing chapters ── */}
        {existingChapters.length > 0 && (
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h3 className="font-semibold text-gray-800 mb-4">
              Existing Chapters ({existingChapters.length})
            </h3>
            <div className="space-y-3">
              {existingChapters.map((ch) => {
                const chNum = Number(ch.chapter_number)
                const isModified = modifiedChapters[chNum]
                const timer = fmtTimer(ch.timer_seconds)
                return (
                  <div key={chNum}
                    className={`border rounded-lg p-4 ${isModified ? 'border-pink-200 bg-pink-50' : 'border-gray-100 bg-gray-50'}`}>
                    <div className="flex items-start justify-between gap-2 mb-3">
                      <span className="text-sm font-medium text-gray-700">
                        Ch. {chNum} {isModified && <span className="text-pink-500 text-xs">*modified</span>}
                      </span>
                      <button type="button" onClick={() => handleDeleteExisting(ch)}
                        disabled={deletingCh === chNum}
                        className="p-1 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded disabled:opacity-40">
                        <IconTrash className="w-4 h-4" />
                      </button>
                    </div>

                    <div className="grid grid-cols-2 gap-3 mb-3">
                      <div>
                        <label className="block text-xs text-gray-500 mb-1">Title</label>
                        <input value={ch.chapter_title || ''}
                          onChange={(e) => updateExistingCh(chNum, 'chapter_title', e.target.value)}
                          className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm" />
                      </div>
                      <div>
                        <label className="block text-xs text-gray-500 mb-1">Replace file</label>
                        <FileUpload folder="chapters" accept={CHAPTER_ACCEPT}
                          label="Upload new file"
                          onUploaded={({ s3_url }) => updateExistingCh(chNum, 'new_content_url', s3_url)} />
                        {ch.new_content_url && <p className="text-xs text-green-600 mt-1">✓ New file ready</p>}
                        {!ch.new_content_url && ch.content_url && (
                          <p className="text-xs text-gray-400 mt-1 truncate">📄 {ch.content_url.split('/').pop()}</p>
                        )}
                      </div>
                    </div>

                    <div className="grid grid-cols-3 gap-3 mb-3">
                      <div>
                        <label className="block text-xs text-gray-500 mb-1">Coins</label>
                        <input type="number" min="0" value={Number(ch.price_to_unlock) || 0}
                          onChange={(e) => updateExistingCh(chNum, 'price_to_unlock', e.target.value)}
                          className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm" />
                      </div>
                      <div>
                        <label className="block text-xs text-gray-500 mb-1">
                          Timer (min){timer && <span className="ml-1 text-gray-400">= {timer}</span>}
                        </label>
                        <input type="number" min="0" value={ch.timer_min ?? 0}
                          onChange={(e) => {
                            const mins = e.target.value
                            updateExistingCh(chNum, 'timer_min', mins)
                            updateExistingCh(chNum, 'timer_seconds', Number(mins) * 60)
                          }}
                          className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm" />
                      </div>
                      <div>
                        <label className="block text-xs text-gray-500 mb-1">Ads</label>
                        <input type="number" min="0" value={Number(ch.reward_ads_count) || 0}
                          onChange={(e) => updateExistingCh(chNum, 'reward_ads_count', e.target.value)}
                          className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm" />
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>
        )}

        {/* ── New chapters ── */}
        <div className="bg-white rounded-xl border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-gray-800">
              Add New Chapters {newChapters.length > 0 && <span className="text-sm text-pink-500">({newChapters.length})</span>}
            </h3>
            <div className="flex items-center gap-2">
              {/* Bulk file upload */}
              <label className={`cursor-pointer inline-flex items-center gap-2 text-sm border border-gray-300 text-gray-700 px-3 py-1.5 rounded-lg hover:bg-gray-50 transition ${bulkAdding ? 'opacity-50 pointer-events-none' : ''}`}>
                <input
                  ref={bulkFileRef}
                  type="file"
                  multiple
                  accept={CHAPTER_ACCEPT}
                  className="hidden"
                  onChange={handleBulkFileUpload}
                  disabled={bulkAdding}
                />
                {bulkAdding ? '⏳ Uploading…' : '📁 Bulk upload files'}
              </label>
              <button type="button" onClick={addNewChapter}
                className="text-sm text-pink-600 border border-pink-200 px-3 py-1.5 rounded-lg hover:bg-pink-50 transition">
                + Add one
              </button>
            </div>
          </div>

          {newChapters.length === 0 ? (
            <p className="text-sm text-gray-400 text-center py-4">
              Use "📁 Bulk upload files" to select multiple .docx/.txt files at once
              (first 10 free, rest: 1 coin / 1h / 1 ad), or "+ Add one" for manual control.
            </p>
          ) : (
            <div className="space-y-3">
              {newChapters.map((ch, idx) => (
                <div key={ch.id} className="border border-pink-100 rounded-lg p-4 bg-pink-50">
                  <div className="flex items-center justify-between mb-3">
                    <span className="text-sm font-semibold text-gray-700">
                      New Ch. {existingChapters.length + idx + 1}
                      {ch.is_free ? (
                        <span className="ml-2 text-xs text-green-600 font-normal">Free</span>
                      ) : (
                        <span className="ml-2 text-xs text-gray-500 font-normal">
                          {ch.price} coin · {ch.timer_min}min · {ch.ads} ad
                        </span>
                      )}
                    </span>
                    <button type="button" onClick={() => removeNewCh(ch.id)}
                      className="p-1 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded">
                      <IconTrash className="w-4 h-4" />
                    </button>
                  </div>

                  <div className="grid grid-cols-2 gap-3 mb-3">
                    <div>
                      <label className="block text-xs text-gray-500 mb-1">Title</label>
                      <input value={ch.title} onChange={(e) => updateNewCh(ch.id, 'title', e.target.value)}
                        className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm" />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-500 mb-1">File</label>
                      <FileUpload folder="chapters" accept={CHAPTER_ACCEPT}
                        label="Upload (.docx .txt .pdf…)"
                        onUploaded={({ s3_url }) => updateNewCh(ch.id, 'content_url', s3_url)} />
                      {ch.content_url && <p className="text-xs text-green-600 mt-1">✓ Uploaded</p>}
                    </div>
                  </div>

                  <div className="grid grid-cols-4 gap-2">
                    <div>
                      <label className="flex items-center gap-1 text-xs text-gray-500 mb-1 cursor-pointer">
                        <input type="checkbox" checked={ch.is_free}
                          onChange={(e) => updateNewCh(ch.id, 'is_free', e.target.checked)} className="accent-pink-500" />
                        Free
                      </label>
                    </div>
                    <div>
                      <label className="block text-xs text-gray-500 mb-1">Coins</label>
                      <input type="number" min="0" value={ch.price}
                        onChange={(e) => updateNewCh(ch.id, 'price', e.target.value)}
                        disabled={ch.is_free}
                        className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm disabled:opacity-50" />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-500 mb-1">Timer (min)</label>
                      <input type="number" min="0" value={ch.timer_min}
                        onChange={(e) => updateNewCh(ch.id, 'timer_min', e.target.value)}
                        disabled={ch.is_free}
                        className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm disabled:opacity-50" />
                    </div>
                    <div>
                      <label className="block text-xs text-gray-500 mb-1">Ads</label>
                      <input type="number" min="0" value={ch.ads}
                        onChange={(e) => updateNewCh(ch.id, 'ads', e.target.value)}
                        disabled={ch.is_free}
                        className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm disabled:opacity-50" />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {error && <p className="text-sm text-red-500 bg-red-50 rounded-lg px-3 py-2">{error}</p>}
        {success && <p className="text-sm text-green-600 bg-green-50 rounded-lg px-3 py-2">{success}</p>}

        <div className="flex gap-3">
          <button type="submit" disabled={saving}
            className="bg-pink-600 text-white px-6 py-2.5 rounded-lg text-sm font-medium hover:bg-pink-700 disabled:opacity-50 transition">
            {saving ? 'Saving…' : 'Save Changes'}
          </button>
          <Link to={`/books/${id}`}
            className="border border-gray-300 text-gray-700 px-6 py-2.5 rounded-lg text-sm font-medium hover:bg-gray-50 transition">
            Cancel
          </Link>
        </div>
      </form>
    </div>
  )
}
