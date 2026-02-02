interface Pack {
  id: string;
  name: string;
  description: string;
  image: string;
  requiresBooster: boolean;
  rewards: Array<{
    type: string;
    name?: string;
    account?: string;
    label: string;
    amount: number;
  }>;
  claimed: boolean;
  canClaim: boolean;
}

interface StarterPackCardProps {
  pack: Pack;
  onClaim: (packId: string) => void;
}

export default function StarterPackCard({ pack, onClaim }: StarterPackCardProps) {
  const handleClaim = () => {
    if (!pack.claimed && pack.canClaim) {
      onClaim(pack.id);
    }
  };

  return (
    <div className="bg-zinc-900 border border-zinc-800 rounded-lg overflow-hidden hover:border-zinc-700 transition-all flex flex-col h-full">
      {/* Header Badge */}
      <div className="relative">
        <div className="absolute top-3 left-3 px-3 py-1 bg-zinc-800/90 backdrop-blur-sm rounded-md text-xs font-semibold text-zinc-300 border border-zinc-700">
          Starter Pack
        </div>
        
        {/* Pack Image */}
        <div className="h-48 bg-gradient-to-br from-zinc-800 to-zinc-900 flex items-center justify-center border-b border-zinc-800 p-4">
          {pack.image ? (
            <img src={pack.image} alt={pack.name} className="max-w-full max-h-full object-contain" />
          ) : (
            <div className="text-6xl">🎁</div>
          )}
        </div>
      </div>

      {/* Content */}
      <div className="p-5 flex-1 flex flex-col">
        <h3 className="text-lg font-bold text-white mb-1">{pack.name}</h3>
        <p className="text-sm text-zinc-400 mb-4">{pack.description}</p>

        {/* Rewards List */}
        <div className="space-y-1.5 mb-4 flex-1">
          {pack.rewards.map((reward, index) => (
            <div key={index} className="flex items-center gap-2 text-sm">
              <span className="w-1.5 h-1.5 bg-amber-500 rounded-full"></span>
              <span className="text-zinc-300">
                {reward.type === 'item' && `${reward.label}`}
                {reward.type === 'money' && `${reward.label}: ${reward.amount.toLocaleString()}`}
                {reward.amount > 1 && reward.type === 'item' && ` x${reward.amount}`}
              </span>
            </div>
          ))}
        </div>

        {/* Booster Badge */}
        {pack.requiresBooster && (
          <div className="mb-3 px-3 py-1.5 bg-purple-500/10 border border-purple-500/30 rounded-md text-xs text-purple-400 font-medium flex items-center gap-2">
            <span>⚡</span>
            <span>Discord Booster Required</span>
          </div>
        )}

        {/* Claim Status */}
        <div className="text-xs text-zinc-500 mb-3">
          {pack.claimed ? 'Already claimed' : 'One-time claim only'}
        </div>

        {/* Claim Button */}
        <button
          onClick={handleClaim}
          disabled={pack.claimed || !pack.canClaim}
          className={`w-full py-2.5 rounded-lg font-semibold text-sm transition-all ${
            pack.claimed
              ? 'bg-zinc-800 text-zinc-600 cursor-not-allowed'
              : !pack.canClaim
              ? 'bg-zinc-800 text-zinc-600 cursor-not-allowed'
              : 'bg-gradient-to-r from-amber-500 to-orange-600 text-white hover:from-amber-600 hover:to-orange-700 shadow-lg shadow-orange-500/20'
          }`}
        >
          {pack.claimed ? 'Claimed' : !pack.canClaim ? 'Cannot Claim' : 'Claim Now'}
        </button>
      </div>
    </div>
  );
}