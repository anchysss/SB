import { useRef, useState } from 'react'
import SignatureCanvas from 'react-signature-canvas'

export default function SignaturePad({ onSave, onCancel }) {
  const canvasRef = useRef()
  const [empty, setEmpty] = useState(true)

  const handleSave = () => {
    if (canvasRef.current.isEmpty()) return
    const dataUrl = canvasRef.current.getTrimmedCanvas().toDataURL('image/png')
    onSave(dataUrl)
  }

  const handleClear = () => {
    canvasRef.current.clear()
    setEmpty(true)
  }

  return (
    <div className="bg-white border border-gray-200 rounded-xl p-4 shadow-sm">
      <p className="text-sm font-medium text-gray-700 mb-2">Sign below:</p>
      <div className="border border-gray-300 rounded-lg overflow-hidden bg-gray-50">
        <SignatureCanvas
          ref={canvasRef}
          penColor="#1f2937"
          canvasProps={{ width: 500, height: 180, className: 'w-full' }}
          onBegin={() => setEmpty(false)}
        />
      </div>
      <div className="flex gap-2 mt-3">
        <button
          type="button"
          onClick={handleSave}
          disabled={empty}
          className="px-4 py-2 bg-pink-600 text-white text-sm rounded-lg disabled:opacity-50 hover:bg-pink-700 transition"
        >
          Save Signature
        </button>
        <button
          type="button"
          onClick={handleClear}
          className="px-4 py-2 border border-gray-300 text-sm text-gray-700 rounded-lg hover:bg-gray-50 transition"
        >
          Clear
        </button>
        {onCancel && (
          <button
            type="button"
            onClick={onCancel}
            className="px-4 py-2 border border-gray-300 text-sm text-gray-700 rounded-lg hover:bg-gray-50 transition ml-auto"
          >
            Cancel
          </button>
        )}
      </div>
    </div>
  )
}
