import { useEffect, useState } from 'react'
import { useParams, Link } from 'react-router-dom'
import { getWriter, getWriterBooks, getWriterEarnings, recordEarnings, updateWriter, getContracts, uploadContract, signContract } from '../api'
import StatusBadge from '../components/StatusBadge'
import FileUpload from '../components/FileUpload'
import SignaturePad from '../components/SignaturePad'

export default function WriterDetail() {
  const { id } = useParams()
  const [writer, setWriter] = useState(null)
  const [books, setBooks] = useState([])
  const [earnings, setEarnings] = useState([])
  const [loading, setLoading] = useState(true)
  const [earningForm, setEarningForm] = useState({ month: '', amount: '', note: '' })
  const [recording, setRecording] = useState(false)
  const [editing, setEditing] = useState(false)
  const [editForm, setEditForm] = useState({})
  const [saving, setSaving] = useState(false)
  const [tab, setTab] = useState('books')
  const [contracts, setContracts] = useState([])
  const [contractFile, setContractFile] = useState(null)
  const [uploadingContract, setUploadingContract] = useState(false)
  const [showSig, setShowSig] = useState(null)

  useEffect(() => {
    loadData()
  }, [id])

  async function loadData() {
    try {
      const [writerRes, booksRes, earningsRes, contractsRes] = await Promise.all([
        getWriter(id),
        getWriterBooks(id),
        getWriterEarnings(id),
        getContracts(id),
      ])
      setWriter(writerRes.writer)
      setBooks(booksRes.books || [])
      setEarnings(earningsRes.earnings || [])
      setContracts(contractsRes.contracts || [])
    } catch (err) {
      console.error(err)
    } finally {
      setLoading(false)
    }
  }

  async function handleRecordEarning(e) {
    e.preventDefault()
    if (!earningForm.month || !earningForm.amount) return
    setRecording(true)
    try {
      await recordEarnings({
        writer_id: id,
        month: earningForm.month,
        amount: parseFloat(earningForm.amount),
        note: earningForm.note,
      })
      setEarningForm({ month: '', amount: '', note: '' })
      await loadData()
    } catch (err) {
      alert(err.message)
    } finally {
      setRecording(false)
    }
  }

  async function handleSaveEdit(e) {
    e.preventDefault()
    setSaving(true)
    try {
      // Lambda updateWriter expects user_id
      await updateWriter({ user_id: id, ...editForm })
      setEditing(false)
      await loadData()
    } catch (err) {
      alert(err.message)
    } finally {
      setSaving(false)
    }
  }

  const startEdit = () => {
    setEditForm({ name: writer.name, email: writer.email, bio: writer.bio || '', phone: writer.phone || '', status: writer.status || 'active' })
    setEditing(true)
  }

  // Lambda stores total_payout (15% of revenue) per month entry
  const totalEarned = earnings.reduce((s, e) => s + (parseFloat(e.total_payout) || parseFloat(e.amount) || 0), 0)

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-pink-500" />
      </div>
    )
  }

  if (!writer) {
    return <div className="text-center py-20 text-gray-400">Writer not found.</div>
  }

  return (
    <div className="space-y-6">
      {/* Writer Profile */}
      <div className="bg-white rounded-xl border border-gray-200 p-6">
        <div className="flex items-start justify-between mb-4">
          <div>
            <h2 className="text-2xl font-bold text-gray-900">{writer.name}</h2>
            <p className="text-gray-500 text-sm mt-1">{writer.email}</p>
            {writer.phone && <p className="text-gray-400 text-xs">{writer.phone}</p>}
          </div>
          <div className="flex items-center gap-3">
            <StatusBadge status={writer.status || 'active'} />
            <button
              onClick={startEdit}
              className="text-sm text-pink-600 border border-pink-200 px-3 py-1.5 rounded-lg hover:bg-pink-50"
            >
              Edit
            </button>
          </div>
        </div>

        {editing ? (
          <form onSubmit={handleSaveEdit} className="space-y-3 mt-4 border-t pt-4">
            <div className="grid grid-cols-2 gap-3">
              <div>
                <label className="text-xs text-gray-500">Name</label>
                <input value={editForm.name} onChange={(e) => setEditForm((p) => ({ ...p, name: e.target.value }))}
                  className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm mt-1" />
              </div>
              <div>
                <label className="text-xs text-gray-500">Email</label>
                <input value={editForm.email} onChange={(e) => setEditForm((p) => ({ ...p, email: e.target.value }))}
                  className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm mt-1" />
              </div>
              <div>
                <label className="text-xs text-gray-500">Phone</label>
                <input value={editForm.phone} onChange={(e) => setEditForm((p) => ({ ...p, phone: e.target.value }))}
                  className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm mt-1" />
              </div>
              <div>
                <label className="text-xs text-gray-500">Status</label>
                <select value={editForm.status} onChange={(e) => setEditForm((p) => ({ ...p, status: e.target.value }))}
                  className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm mt-1">
                  <option value="active">active</option>
                  <option value="inactive">inactive</option>
                </select>
              </div>
            </div>
            <div>
              <label className="text-xs text-gray-500">Bio</label>
              <textarea value={editForm.bio} onChange={(e) => setEditForm((p) => ({ ...p, bio: e.target.value }))}
                rows={2} className="w-full border border-gray-200 rounded px-2 py-1.5 text-sm mt-1" />
            </div>
            <div className="flex gap-2">
              <button type="submit" disabled={saving} className="bg-pink-600 text-white px-4 py-1.5 rounded text-sm disabled:opacity-50">
                {saving ? 'Saving…' : 'Save'}
              </button>
              <button type="button" onClick={() => setEditing(false)} className="border border-gray-300 text-gray-600 px-4 py-1.5 rounded text-sm">
                Cancel
              </button>
            </div>
          </form>
        ) : writer.bio ? (
          <p className="text-sm text-gray-600 mt-3">{writer.bio}</p>
        ) : null}
      </div>

      {/* Earnings Summary */}
      <div className="grid grid-cols-2 gap-4">
        <div className="bg-green-50 border border-green-200 rounded-xl p-5">
          <p className="text-sm text-green-700 font-medium">Total Earned</p>
          <p className="text-3xl font-bold text-green-800 mt-1">${totalEarned.toFixed(2)}</p>
        </div>
        <div className="bg-pink-50 border border-pink-200 rounded-xl p-5">
          <p className="text-sm text-pink-700 font-medium">Books Published</p>
          <p className="text-3xl font-bold text-pink-800 mt-1">
            {books.filter((b) => b.status === 'published').length}
          </p>
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 bg-gray-100 p-1 rounded-lg w-fit">
        {['books', 'earnings', 'contracts'].map((t) => (
          <button key={t} onClick={() => setTab(t)}
            className={`px-4 py-1.5 rounded-md text-sm font-medium transition capitalize ${tab === t ? 'bg-white shadow text-gray-900' : 'text-gray-500 hover:text-gray-700'}`}>
            {t}
          </button>
        ))}
      </div>

      {tab === 'books' && (
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
            <h3 className="font-semibold text-gray-800">Books by {writer.name}</h3>
          </div>
          {books.length === 0 ? (
            <p className="text-sm text-gray-400 text-center py-8">No books yet.</p>
          ) : (
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-gray-100 bg-gray-50 text-left">
                  <th className="px-4 py-3 font-medium text-gray-600">Title</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Status</th>
                  <th className="px-4 py-3 font-medium text-gray-600">Actions</th>
                </tr>
              </thead>
              <tbody>
                {books.map((b) => (
                  <tr key={b.book_id} className="border-b border-gray-50 hover:bg-gray-50">
                    <td className="px-4 py-3 font-medium text-gray-900">{b.book_name}</td>
                    <td className="px-4 py-3"><StatusBadge status={b.status || 'published'} /></td>
                    <td className="px-4 py-3">
                      <Link to={`/books/${b.book_id}`} className="text-xs text-pink-600 hover:underline">View</Link>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>
      )}

      {tab === 'contracts' && (
        <div className="space-y-4">
          {/* Upload Contract */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h3 className="font-semibold text-gray-800 mb-4">Upload Contract</h3>
            <div className="flex items-end gap-3">
              <FileUpload
                folder="contracts"
                accept=".pdf,application/pdf"
                label="Upload PDF"
                onUploaded={setContractFile}
              />
              {contractFile && (
                <button
                  onClick={async () => {
                    setUploadingContract(true)
                    try {
                      await uploadContract({ writer_id: id, s3_url: contractFile.s3_url, contract_name: contractFile.name })
                      setContractFile(null)
                      await loadData()
                    } catch (err) { alert(err.message) }
                    finally { setUploadingContract(false) }
                  }}
                  disabled={uploadingContract}
                  className="bg-pink-600 text-white px-4 py-2 rounded-lg text-sm disabled:opacity-50"
                >
                  {uploadingContract ? 'Saving…' : 'Save Contract'}
                </button>
              )}
            </div>
          </div>

          {/* Contract List */}
          <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-100">
              <h3 className="font-semibold text-gray-800">Contracts</h3>
            </div>
            {contracts.length === 0 ? (
              <p className="text-sm text-gray-400 text-center py-8">No contracts yet.</p>
            ) : (
              <div className="divide-y divide-gray-50">
                {contracts.map((c) => (
                  <div key={c.contract_id} className="px-6 py-4 flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-gray-900">{c.contract_name || 'Contract'}</p>
                      <p className="text-xs text-gray-400 mt-0.5">
                        Uploaded {c.uploaded_at ? new Date(c.uploaded_at).toLocaleDateString() : '—'}
                      </p>
                    </div>
                    <div className="flex items-center gap-3">
                      <StatusBadge status={c.status || 'unsigned'} />
                      {c.s3_url && (
                        <a href={c.s3_url} target="_blank" rel="noreferrer"
                          className="text-xs text-pink-600 hover:underline">View PDF</a>
                      )}
                      {c.status !== 'signed' && (
                        <button onClick={() => setShowSig(c.contract_id)}
                          className="text-xs text-blue-600 hover:underline">Sign</button>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {showSig && (
            <SignaturePad
              onSave={async (sig) => {
                try {
                  await signContract({ writer_id: id, contract_id: showSig, signature_data: sig })
                  setShowSig(null)
                  await loadData()
                } catch (err) { alert(err.message) }
              }}
              onCancel={() => setShowSig(null)}
            />
          )}
        </div>
      )}

      {tab === 'earnings' && (
        <div className="space-y-4">
          {/* Record Earning */}
          <div className="bg-white rounded-xl border border-gray-200 p-6">
            <h3 className="font-semibold text-gray-800 mb-4">Record Earning</h3>
            <form onSubmit={handleRecordEarning} className="grid grid-cols-3 gap-3 items-end">
              <div>
                <label className="text-xs text-gray-500 mb-1 block">Month (YYYY-MM)</label>
                <input
                  type="month"
                  value={earningForm.month}
                  onChange={(e) => setEarningForm((p) => ({ ...p, month: e.target.value }))}
                  className="w-full border border-gray-300 rounded-lg px-2 py-2 text-sm focus:outline-none focus:ring-1 focus:ring-pink-400"
                />
              </div>
              <div>
                <label className="text-xs text-gray-500 mb-1 block">Amount ($)</label>
                <input
                  type="number" min="0" step="0.01"
                  value={earningForm.amount}
                  onChange={(e) => setEarningForm((p) => ({ ...p, amount: e.target.value }))}
                  className="w-full border border-gray-300 rounded-lg px-2 py-2 text-sm focus:outline-none focus:ring-1 focus:ring-pink-400"
                  placeholder="0.00"
                />
              </div>
              <button
                type="submit"
                disabled={recording}
                className="bg-pink-600 text-white py-2 rounded-lg text-sm disabled:opacity-50"
              >
                {recording ? 'Saving…' : 'Record'}
              </button>
            </form>
          </div>

          {/* Earnings History */}
          <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-100">
              <h3 className="font-semibold text-gray-800">Earnings History (15% share)</h3>
            </div>
            {earnings.length === 0 ? (
              <p className="text-sm text-gray-400 text-center py-8">No earnings recorded.</p>
            ) : (
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-gray-100 bg-gray-50 text-left">
                    <th className="px-4 py-3 font-medium text-gray-600">Month</th>
                    <th className="px-4 py-3 font-medium text-gray-600">Amount</th>
                    <th className="px-4 py-3 font-medium text-gray-600">Note</th>
                  </tr>
                </thead>
                <tbody>
                  {earnings.map((e) => (
                    <tr key={e.month} className="border-b border-gray-50 hover:bg-gray-50">
                      <td className="px-4 py-3 font-medium text-gray-900">{e.month}</td>
                      <td className="px-4 py-3 text-green-700 font-semibold">
                        ${parseFloat(e.total_payout || e.amount || 0).toFixed(2)}
                        {e.total_revenue && (
                          <span className="text-xs text-gray-400 ml-2">(rev: ${parseFloat(e.total_revenue).toFixed(2)})</span>
                        )}
                      </td>
                      <td className="px-4 py-3 text-gray-500">{e.note || '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      )}
    </div>
  )
}
