const colors = {
  pending:   'bg-yellow-100 text-yellow-800',
  approved:  'bg-blue-100 text-blue-800',
  published: 'bg-green-100 text-green-800',
  rejected:  'bg-red-100 text-red-800',
  signed:    'bg-green-100 text-green-800',
  active:    'bg-green-100 text-green-800',
  inactive:  'bg-gray-100 text-gray-600',
}

export default function StatusBadge({ status }) {
  const cls = colors[status] || 'bg-gray-100 text-gray-600'
  return (
    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${cls}`}>
      {status}
    </span>
  )
}
