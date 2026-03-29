import { auth } from './firebase'

const ADMIN_API = import.meta.env.VITE_ADMIN_API_URL
const PRESIGNED_API = import.meta.env.VITE_PRESIGNED_URL

async function getToken() {
  const user = auth.currentUser
  if (!user) throw new Error('Not authenticated')
  return user.getIdToken()
}

async function callApi(action, payload = {}) {
  const token = await getToken()
  const res = await fetch(ADMIN_API, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({ action, ...payload }),
  })
  const data = await res.json()
  if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`)
  return data
}

// ─── Writers ─────────────────────────────────────────────────────────────────
// Writers table PK is `user_id`
export const getWriters = () => callApi('getWriters')
export const getWriter = (user_id) => callApi('getWriter', { user_id })
export const createWriter = (payload) => callApi('createWriter', payload)
export const updateWriter = (payload) => callApi('updateWriter', payload)

// ─── Books ───────────────────────────────────────────────────────────────────
// Lambda uses: book_name, author_name, genre[], short_summary, cover_image_url
// Chapters use: chapter_title, price_to_unlock, timer_seconds, reward_ads_count
export const getBooks = () => callApi('getBooks')
export const getPendingBooks = () => callApi('getPendingBooks')

// Lambda approveBook uses approved=true/false (not status string)
export const approveBook = (book_id, approved) =>
  callApi('approveBook', { book_id, approved })

// Activate or deactivate a book (inactive = hidden in mobile app)
export const setBookActive = (book_id, active) =>
  callApi('setBookActive', { book_id, active })

// Map frontend-friendly names → Lambda field names
function mapBookPayload(form, chapters) {
  return {
    book_name: form.title,
    author_name: form.author,
    // genres is now an array (multi-select checkboxes)
    genre: Array.isArray(form.genres) ? form.genres : (form.category ? [form.category] : []),
    short_summary: form.description,
    cover_image_url: form.cover_url,
    tags: Array.isArray(form.tags) ? form.tags : (form.tags || '').split(',').map((t) => t.trim()).filter(Boolean),
    writer_id: form.writer_id || '',
    chapters: (chapters || []).map((c, idx) => ({
      chapter_number: idx + 1,
      chapter_title: c.title,
      content_url: c.content_url || '',
      price_to_unlock: Number(c.price) || 0,
      timer_seconds: Number(c.timer_sec) || 0,
      reward_ads_count: Number(c.ads) || 0,
    })),
  }
}

export const createBook = (form, chapters) =>
  callApi('createBook', mapBookPayload(form, chapters))

export const submitBook = (form, chapters) =>
  callApi('submitBook', mapBookPayload(form, chapters))

// updateChapter uses Lambda field names directly:
// { book_id, chapter_number, chapter_title?, price_to_unlock?, timer_seconds?, reward_ads_count? }
export const updateChapter = (payload) => callApi('updateChapter', payload)
export const updateBook = (payload) => callApi('updateBook', payload)
export const getBookChapters = (book_id) => callApi('getBookChapters', { book_id })
export const addChapters = (book_id, chapters) => callApi('addChapters', { book_id, chapters })
export const deleteChapter = (book_id, chapter_number) => callApi('deleteChapter', { book_id, chapter_number })
export const deleteBook = (book_id) => callApi('deleteBook', { book_id })
export const reprocessBookChapters = (book_id) => callApi('reprocessBookChapters', { book_id })
export const getWriterBooks = (writer_id) => callApi('getWriterBooks', { writer_id })

// ─── Earnings ────────────────────────────────────────────────────────────────
// getEarnings without month gets current month (admin view of all writers)
export const getEarnings = (month) => callApi('getEarnings', month ? { month } : {})
export const getWriterEarnings = (writer_id) => callApi('getWriterEarnings', { writer_id })
// amount = total chapter revenue; Lambda auto-computes 15% payout
export const recordEarnings = (payload) => callApi('recordEarnings', payload)

// ─── Contracts ───────────────────────────────────────────────────────────────
// Contracts are per-writer; getContracts requires writer_id
export const getContracts = (writer_id) => callApi('getContracts', { writer_id })
export const uploadContract = (payload) => callApi('uploadContract', payload)
export const signContract = (payload) => callApi('signContract', payload)

// ─── File Upload ─────────────────────────────────────────────────────────────
export async function getPresignedUrl(filename, content_type, folder) {
  const token = await getToken()
  const res = await fetch(PRESIGNED_API, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({ filename, content_type, folder }),
  })
  const data = await res.json()
  if (!res.ok) throw new Error(data.error || 'Failed to get upload URL')
  return data // { upload_url, s3_url, key }
}

export async function uploadFile(file, folder) {
  const contentType = file.type || 'application/octet-stream'
  const { upload_url, s3_url, key } = await getPresignedUrl(file.name, contentType, folder)
  const putRes = await fetch(upload_url, {
    method: 'PUT',
    headers: { 'Content-Type': contentType },
    body: file,
  })
  if (!putRes.ok) throw new Error(`File upload failed (${putRes.status}). Please try again.`)
  return { s3_url, key }
}
