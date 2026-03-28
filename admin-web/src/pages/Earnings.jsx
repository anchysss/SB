import { useEffect, useState } from 'react'
import { getEarnings, getWriters } from '../api'
import { Link } from 'react-router-dom'

export default function Earnings() {
  const [earnings, setEarnings] = useState([])
  const [writers, setWriters] = useState({})
  const [loading, setLoading] = useState(true)
  const [filterMonth, setFilterMonth] = useState('')

  useEffect(() => {
    async function load() {
      try {
        const [earningsRes, writersRes] = await Promise.all([getEarnings(), getWriters()])
        const writerMap = {}
        for (const w of writersRes.writers || []) {
          // Lambda Writers table PK is user_id
          writerMap[w.user_id] = w
        }
        setWriters(writerMap)
        setEarnings(earningsRes.earnings || [])
      } catch (err) {
        console.error(err)
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [])

  const filtered = filterMonth
    ? earnings.filter((e) => e.month === filterMonth)
    : earnings

  const total = filtered.reduce((s, e) => s + (parseFloat(e.total_payout) || parseFloat(e.amount) || 0), 0)

  return (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">All Earnings</h2>

      <div className="flex items-center gap-4 mb-6">
        <div>
          <label className="text-xs text-gray-500 mb-1 block">Filter by month</label>
          <input
            type="month"
            value={filterMonth}
            onChange={(e) => setFilterMonth(e.target.value)}
            className="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-pink-400"
          />
        </div>
        {filterMonth && (
          <button
            onClick={() => setFilterMonth('')}
            className="mt-5 text-xs text-gray-400 hover:text-gray-600"
          >
            ✕ Clear
          </button>
        )}
        <div className="ml-auto bg-green-50 border border-green-200 rounded-xl px-5 py-3">
          <p className="text-xs text-green-700">
            {filterMonth ? `Total for ${filterMonth}` : 'Grand Total'}
          </p>
          <p className="text-2xl font-bold text-green-800">${total.toFixed(2)}</p>
        </div>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-40">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-pink-500" />
        </div>
      ) : filtered.length === 0 ? (
        <div className="text-center py-16 text-gray-400">No earnings found.</div>
      ) : (
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50 text-left">
                <th className="px-4 py-3 font-medium text-gray-600">Writer</th>
                <th className="px-4 py-3 font-medium text-gray-600">Month</th>
                <th className="px-4 py-3 font-medium text-gray-600">Amount (15%)</th>
                <th className="px-4 py-3 font-medium text-gray-600">Note</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((e, i) => {
                const w = writers[e.writer_id]
                return (
                  <tr key={i} className="border-b border-gray-50 hover:bg-gray-50">
                    <td className="px-4 py-3">
                      {w ? (
                        <Link to={`/writers/${e.writer_id}`} className="text-pink-600 hover:underline font-medium">
                          {w.name}
                        </Link>
                      ) : (
                        <span className="text-gray-500">{e.writer_id}</span>
                      )}
                    </td>
                    <td className="px-4 py-3 text-gray-700">{e.month}</td>
                    <td className="px-4 py-3 text-green-700 font-semibold">${parseFloat(e.total_payout || e.amount || 0).toFixed(2)}</td>
                    <td className="px-4 py-3 text-gray-500">{e.note || '—'}</td>
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
