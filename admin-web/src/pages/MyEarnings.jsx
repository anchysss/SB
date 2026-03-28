import { useEffect, useState } from 'react'
import { getWriterEarnings } from '../api'
import { useAuth } from '../context/AuthContext'

export default function MyEarnings() {
  const { profile } = useAuth()
  const [earnings, setEarnings] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (profile?.user_id) {
      getWriterEarnings(profile.user_id)
        .then((res) => setEarnings(res.earnings || []))
        .catch(console.error)
        .finally(() => setLoading(false))
    }
  }, [profile])

  // Lambda stores total_payout (15% of revenue) per month
  const total = earnings.reduce((s, e) => s + (parseFloat(e.total_payout) || parseFloat(e.amount) || 0), 0)

  return (
    <div>
      <h2 className="text-2xl font-bold text-gray-900 mb-6">My Earnings</h2>

      <div className="grid grid-cols-2 gap-4 mb-6">
        <div className="bg-green-50 border border-green-200 rounded-xl p-5">
          <p className="text-sm text-green-700 font-medium">Total Earned</p>
          <p className="text-3xl font-bold text-green-800 mt-1">${total.toFixed(2)}</p>
        </div>
        <div className="bg-pink-50 border border-pink-200 rounded-xl p-5">
          <p className="text-sm text-pink-700 font-medium">Your Share</p>
          <p className="text-2xl font-bold text-pink-800 mt-1">15% of chapter revenue</p>
          <p className="text-xs text-pink-600 mt-1">Paid monthly by admin</p>
        </div>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-40">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-pink-500" />
        </div>
      ) : earnings.length === 0 ? (
        <div className="text-center py-16 text-gray-400">No earnings recorded yet.</div>
      ) : (
        <div className="bg-white rounded-xl border border-gray-200 overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-gray-50 text-left">
                <th className="px-4 py-3 font-medium text-gray-600">Month</th>
                <th className="px-4 py-3 font-medium text-gray-600">Amount</th>
                <th className="px-4 py-3 font-medium text-gray-600">Note</th>
              </tr>
            </thead>
            <tbody>
              {earnings
                .slice()
                .sort((a, b) => b.month.localeCompare(a.month))
                .map((e) => (
                  <tr key={e.month} className="border-b border-gray-50 hover:bg-gray-50">
                    <td className="px-4 py-3 font-medium text-gray-900">{e.month}</td>
                    <td className="px-4 py-3 text-green-700 font-semibold">
                      ${parseFloat(e.total_payout || e.amount || 0).toFixed(2)}
                    </td>
                    <td className="px-4 py-3 text-gray-500">{e.note || '—'}</td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
