import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { submitBook } from '../api'
import { useAuth } from '../context/AuthContext'
import FileUpload from '../components/FileUpload'

const CATEGORIES = ['Romance', 'Fantasy', 'Thriller', 'Mystery', 'Sci-Fi', 'Historical', 'Contemporary', 'Erotic']

export default function MyBookNew() {
  const navigate = useNavigate()
  const { profile } = useAuth()

  const [form, setForm] = useState({
    title: '', description: '', category: 'Romance', tags: '', cover_url: '',
  })
  const [chapters, setChapters] = useState([])
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')

  const set = (k, v) => setForm((f) => ({ ...f, [k]: v }))

  const addChapter = () =>
    setChapters((prev) => [
      ...prev,
      {
        id: Date.now(),
        title: `Chapter ${prev.length + 1}`,
        content_url: '',
        price: 0,
        timer_sec: 0,
        ads: 0,
        is_free: true,
      },
    ])

  const updateCh = (id, key, val) =>
    setChapters((prev) => prev.map((c) => (c.id === id ? { ...c, [key]: val } : c)))

  const removeChapter = (id) => setChapters((prev) => prev.filter((c) => c.id !== id))

  const handleSubmit = async (e) => {
    e.preventDefault()
    if (!form.title.trim()) return setError('Title is required')
    if (!profile?.user_id) return setError('Writer profile not loaded')
    setSaving(true)
    setError('')
    try {
      // submitBook in api.js uses mapBookPayload; pass form + chapters separately
      const formWithWriter = { ...form, writer_id: profile.user_id, author: profile.name }
      await submitBook(formWithWriter, chapters)
      navigate('/my-books')
    } catch (err) {
      setError(err.message)
    } finally {
      setSaving(false)
    }
  }

  return (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-2">Submit New Book</h2>
      <p className="text-sm text-gray-500 mb-6">
        Your book will be reviewed by the admin before publishing.
      </p>

      <form onSubmit={handleSubmit} className="space-y-6">
        {/* Book Info */}
        <div className="bg-white rounded-xl border border-gray-200 p-6 space-y-4">
          <h3 className="font-semibold text-gray-800 mb-2">Book Information</h3>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Title *</label>
            <input
              value={form.title}
              onChange={(e) => set('title', e.target.value)}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-pink-400"
              placeholder="Book title"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
            <textarea
              value={form.description}
              onChange={(e) => set('description', e.target.value)}
              rows={4}
              className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-pink-400"
              placeholder="Book description…"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
              <select
                value={form.category}
                onChange={(e) => set('category', e.target.value)}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-pink-400"
              >
                {CATEGORIES.map((c) => <option key={c}>{c}</option>)}
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Tags (comma separated)</label>
              <input
                value={form.tags}
                onChange={(e) => set('tags', e.target.value)}
                className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-pink-400"
                placeholder="romance, steamy, billionaire"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Cover Image</label>
            <FileUpload
              folder="covers"
              accept="image/*"
              label="Upload Cover"
              onUploaded={({ s3_url }) => set('cover_url', s3_url)}
            />
            {form.cover_url && (
              <img src={form.cover_url} alt="cover preview" className="mt-2 h-24 rounded object-cover" />
            )}
          </div>
        </div>

        {/* Chapters */}
        <div className="bg-white rounded-xl border border-gray-200 p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-gray-800">Chapters</h3>
            <button
              type="button"
              onClick={addChapter}
              className="text-sm text-pink-600 border border-pink-200 px-3 py-1.5 rounded-lg hover:bg-pink-50 transition"
            >
              + Add Chapter
            </button>
          </div>

          {chapters.length === 0 && (
            <p className="text-sm text-gray-400 text-center py-6">
              No chapters added yet. Click "Add Chapter" to begin.
            </p>
          )}

          <div className="space-y-4">
            {chapters.map((ch, idx) => (
              <div key={ch.id} className="border border-gray-100 rounded-lg p-4 bg-gray-50">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-sm font-semibold text-gray-700">Chapter {idx + 1}</span>
                  <button type="button" onClick={() => removeChapter(ch.id)} className="text-xs text-red-400 hover:text-red-600">
                    Remove
                  </button>
                </div>

                <div className="grid grid-cols-2 gap-3 mb-3">
                  <div>
                    <label className="block text-xs text-gray-500 mb-1">Chapter Title</label>
                    <input value={ch.title} onChange={(e) => updateCh(ch.id, 'title', e.target.value)}
                      className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm focus:outline-none focus:ring-1 focus:ring-pink-400" />
                  </div>
                  <div className="flex items-end">
                    <FileUpload folder="chapters" accept=".txt,text/plain" label="Upload .txt"
                      onUploaded={({ s3_url }) => updateCh(ch.id, 'content_url', s3_url)} />
                  </div>
                </div>

                <div className="grid grid-cols-4 gap-3">
                  <div>
                    <label className="block text-xs text-gray-500 mb-1">
                      <input type="checkbox" checked={ch.is_free}
                        onChange={(e) => updateCh(ch.id, 'is_free', e.target.checked)} className="mr-1" />
                      Free
                    </label>
                  </div>
                  <div>
                    <label className="block text-xs text-gray-500 mb-1">Coins</label>
                    <input type="number" min="0" value={ch.price}
                      onChange={(e) => updateCh(ch.id, 'price', e.target.value)}
                      className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm" disabled={ch.is_free} />
                  </div>
                  <div>
                    <label className="block text-xs text-gray-500 mb-1">Timer (sec)</label>
                    <input type="number" min="0" value={ch.timer_sec}
                      onChange={(e) => updateCh(ch.id, 'timer_sec', e.target.value)}
                      className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm" disabled={ch.is_free} />
                  </div>
                  <div>
                    <label className="block text-xs text-gray-500 mb-1">Ads</label>
                    <input type="number" min="0" value={ch.ads}
                      onChange={(e) => updateCh(ch.id, 'ads', e.target.value)}
                      className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm" disabled={ch.is_free} />
                  </div>
                </div>

                {ch.content_url && <p className="mt-2 text-xs text-green-600">✓ File uploaded</p>}
              </div>
            ))}
          </div>
        </div>

        {error && <p className="text-sm text-red-500 bg-red-50 rounded-lg px-3 py-2">{error}</p>}

        <div className="flex gap-3">
          <button type="submit" disabled={saving}
            className="bg-pink-600 text-white px-6 py-2.5 rounded-lg text-sm font-medium hover:bg-pink-700 disabled:opacity-50 transition">
            {saving ? 'Submitting…' : 'Submit for Review'}
          </button>
          <button type="button" onClick={() => navigate('/my-books')}
            className="border border-gray-300 text-gray-700 px-6 py-2.5 rounded-lg text-sm font-medium hover:bg-gray-50 transition">
            Cancel
          </button>
        </div>
      </form>
    </div>
  )
}
