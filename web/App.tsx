import { useState } from 'react';
import { useNuiEvent, fetchNui, debugData } from './hooks/useNui';
import StarterPackCard from './components/StarterPackCard';

// Mock data for browser preview
debugData('setVisible', { visible: true, packs: [
  {
    id: 'civilian',
    name: 'Civilian Starter Pack',
    description: 'Balanced starter bundle for new players.',
    image: 'https://i.imgur.com/placeholder1.png',
    requiresBooster: false,
    rewards: [
      { type: 'item', name: 'WEAPON_PISTOL', label: 'Pistol', amount: 1 },
      { type: 'item', name: 'ammo-9', label: 'Pistol Ammo', amount: 100 },
      { type: 'money', account: 'money', label: 'Cash', amount: 25000 },
      { type: 'item', name: 'phone', label: 'Phone', amount: 1 },
      { type: 'item', name: 'radio', label: 'Radio', amount: 1 }
    ],
    claimed: false,
    canClaim: true
  },
  {
    id: 'booster',
    name: 'Server Booster Pack',
    description: 'Exclusive rewards for Discord boosters.',
    image: 'https://i.imgur.com/placeholder2.png',
    requiresBooster: true,
    rewards: [
      { type: 'item', name: 'WEAPON_CARBINERIFLE', label: 'Carbine Rifle', amount: 1 },
      { type: 'item', name: 'ammo-rifle', label: 'Rifle Ammo', amount: 250 },
      { type: 'money', account: 'money', label: 'Cash', amount: 50000 },
      { type: 'item', name: 'phone', label: 'Phone', amount: 1 },
      { type: 'item', name: 'radio', label: 'Radio', amount: 1 }
    ],
    claimed: false,
    canClaim: false
  }
]});

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

interface NuiData {
  visible: boolean;
  packs: Pack[];
}

export default function App(): JSX.Element {
  const isDebug = typeof (window as any).GetParentResourceName !== 'function';
  const [visible, setVisible] = useState(isDebug);
  const [packs, setPacks] = useState<Pack[]>([]);
  const [searchTerm, setSearchTerm] = useState('');

  useNuiEvent<NuiData>('setVisible', (data) => {
    setVisible(data.visible);
    if (data.packs) {
      setPacks(data.packs);
    }
  });

  const handleClose = () => {
    setVisible(false);
    fetchNui('close');
  };

  const handleClaim = async (packId: string) => {
    await fetchNui('claimPack', { packId });
    // Refresh packs after claiming
    setTimeout(() => {
      window.dispatchEvent(new MessageEvent('message', {
        data: { action: 'refreshPacks' }
      }));
    }, 500);
  };

  const filteredPacks = packs.filter(pack => 
    pack.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    pack.description.toLowerCase().includes(searchTerm.toLowerCase())
  );

  if (!visible) return null;

  return (
    <div className="fixed inset-0 flex items-center justify-center bg-black/60">
      <div className="w-[90vw] h-[90vh] bg-zinc-950 rounded-xl shadow-2xl border border-zinc-800 flex flex-col overflow-hidden">
        {/* Header */}
        <div className="flex items-center justify-between px-8 py-6 border-b border-zinc-800">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 bg-gradient-to-br from-amber-500 to-orange-600 rounded-lg flex items-center justify-center text-2xl">
              📦
            </div>
            <div>
              <h1 className="text-2xl font-bold text-white tracking-tight">Starter Pack Menu</h1>
              <p className="text-sm text-zinc-400">Claim your available starter packs.</p>
            </div>
          </div>
          <button 
            onClick={handleClose}
            className="w-10 h-10 rounded-lg bg-zinc-800 hover:bg-zinc-700 flex items-center justify-center text-zinc-400 hover:text-white transition-colors"
          >
            ✕
          </button>
        </div>

        {/* Tab & Search */}
        <div className="px-8 py-4 border-b border-zinc-800">
          <div className="flex items-center gap-4">
            <button className="px-5 py-2 bg-zinc-800 text-white rounded-lg font-medium text-sm">
              Starter Packs
            </button>
            <div className="flex-1 relative">
              <input
                type="text"
                placeholder="Search starter packs..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full max-w-md px-4 py-2 pl-10 bg-zinc-900 border border-zinc-800 rounded-lg text-white text-sm placeholder-zinc-500 focus:outline-none focus:border-zinc-700"
              />
              <span className="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-500">🔍</span>
            </div>
          </div>
        </div>

        {/* Packs Grid */}
        <div className="flex-1 overflow-y-auto p-8">
          <div className="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-6">
            {filteredPacks.map((pack) => (
              <StarterPackCard
                key={pack.id}
                pack={pack}
                onClaim={handleClaim}
              />
            ))}
          </div>
          
          {filteredPacks.length === 0 && (
            <div className="flex flex-col items-center justify-center h-full text-zinc-500">
              <div className="text-6xl mb-4">📭</div>
              <p className="text-lg">No starter packs found</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
