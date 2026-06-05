import { useState, useRef, useCallback, useEffect } from "react";

/* ─── GOOGLE FONTS ─────────────────────────────────────────────────────────── */
const FONT_LINK = "https://fonts.googleapis.com/css2?family=Baloo+2:wght@400;600;700;800&family=Nunito:wght@400;600;700;800&display=swap";

/* ─── CONSTANTS ─────────────────────────────────────────────────────────────── */
const AFFIRMATIONS = [
  "Every step you take is a step toward the best version of you. 💪",
  "You are stronger than yesterday. Keep going! 🌟",
  "Your body is capable of amazing things. Trust the process. 🌱",
  "Small consistent actions lead to extraordinary results. ✨",
  "You deserve to feel good in your body. Today is a great day to start. 🌸",
  "Progress, not perfection. You are doing wonderfully. 🦋",
  "Your health is your greatest wealth. Invest in yourself today. 💚",
  "Drink water, take steps, grow something beautiful. That is all it takes. 🌿",
];

const SKY = {
  day:       { sky1:"#87CEEB", sky2:"#b8e4f7", gnd1:"#4CAF50", gnd2:"#388E3C", sun:"☀️",  night:false },
  afternoon: { sky1:"#FFD89B", sky2:"#19547B", gnd1:"#5DBB5D", gnd2:"#3a9c3a", sun:"🌤",  night:false },
  sunset:    { sky1:"#ff7e5f", sky2:"#feb47b", gnd1:"#6abf69", gnd2:"#388E3C", sun:"🌅",  night:false },
  night:     { sky1:"#0f2027", sky2:"#203a43", gnd1:"#2d6a2d", gnd2:"#1b4d1b", sun:"🌙",  night:true  },
};

const PLANTS = {
  daisy:     { name:"Daisy",          em:["🌱","🌿","🌼","🌼"], steps:2000,  water:3,  coins:0,   sz:32, desc:"A cheerful starter bloom."         },
  tulip:     { name:"Tulip",          em:["🌱","🌿","🌷","🌷"], steps:3000,  water:4,  coins:0,   sz:32, desc:"Classic and elegant."               },
  cactus:    { name:"Cactus",         em:["🌱","🌱","🌵","🌵"], steps:1500,  water:1,  coins:0,   sz:30, desc:"Low maintenance, high spirit."      },
  sunflower: { name:"Sunflower",      em:["🌱","🌿","🌻","🌻"], steps:5000,  water:6,  coins:80,  sz:38, desc:"Follows the sun, just like you."    },
  rose:      { name:"Rose",           em:["🌱","🌿","🥀","🌹"], steps:6000,  water:8,  coins:100, sz:34, desc:"Worth every single step."           },
  blossom:   { name:"Cherry Blossom", em:["🌱","🌿","🌸","🌸"], steps:8000,  water:10, coins:150, sz:40, desc:"Rare and breathtaking."             },
  tree:      { name:"Oak Tree",       em:["🌱","🌿","🌳","🌲"], steps:15000, water:20, coins:200, sz:48, desc:"A true achievement. Mighty & proud." },
};

const DECOS = [
  { id:"mushroom",  name:"Mushroom",     em:"🍄",  cost:50  },
  { id:"butterfly", name:"Butterfly",    em:"🦋",  cost:80  },
  { id:"lantern",   name:"Lantern",      em:"🏮",  cost:120 },
  { id:"bench",     name:"Garden Bench", em:"🪑",  cost:180 },
  { id:"pond",      name:"Lily Pond",    em:"🪷",  cost:250 },
  { id:"gnome",     name:"Garden Gnome", em:"🧙",  cost:300 },
  { id:"rainbow",   name:"Rainbow",      em:"🌈",  cost:400 },
  { id:"well",      name:"Wishing Well", em:"⛲",  cost:500 },
  { id:"fountain",  name:"Fountain",     em:"⛲",  cost:550 },
  { id:"house",     name:"Tiny House",   em:"🏡",  cost:600 },
  { id:"windmill",  name:"Windmill",     em:"🎡",  cost:700 },
  { id:"treehouse", name:"Tree House",   em:"🏚️", cost:800 },
];

/* ─── HELPERS ───────────────────────────────────────────────────────────────── */
function plantGrowth(pot) {
  const p = PLANTS[pot.type];
  return Math.min(Math.min(pot.stepsAcc / p.steps, 1), Math.min(pot.waterAcc / p.water, 1));
}

function plantStage(growth) {
  if (growth < 0.25) return 0;
  if (growth < 0.5)  return 1;
  if (growth < 0.85) return 2;
  return 3;
}

/* ─── AUDIO ─────────────────────────────────────────────────────────────────── */
function buildAudio() {
  let actx = null;
  function getCtx() {
    if (!actx) actx = new (window.AudioContext || window.webkitAudioContext)();
    return actx;
  }
  function beep(hz, wave, secs, vol, lag) {
    try {
      const c = getCtx();
      const osc = c.createOscillator();
      const gain = c.createGain();
      osc.connect(gain);
      gain.connect(c.destination);
      osc.type = wave;
      osc.frequency.value = hz;
      const t = c.currentTime + (lag || 0);
      gain.gain.setValueAtTime(0, t);
      gain.gain.linearRampToValueAtTime(vol || 0.12, t + 0.05);
      gain.gain.exponentialRampToValueAtTime(0.001, t + secs);
      osc.start(t);
      osc.stop(t + secs);
    } catch (_) {}
  }
  return {
    chime() { [523,659,784].forEach((hz, i) => beep(hz, "sine", 0.5, 0.12, i * 0.15)); },
    water() { for (let i = 0; i < 6; i++) beep(400 + Math.random() * 300, "sine", 0.08, 0.06, i * 0.07); },
    plant() {
      beep(200, "sine", 0.3, 0.1, 0);
      beep(350, "sine", 0.2, 0.08, 0.15);
      [523,659,784,1047].forEach((hz, i) => beep(hz, "sine", 0.5, 0.12, 0.3 + i * 0.1));
    },
    coins() { for (let i = 0; i < 5; i++) beep(800 + i * 150, "triangle", 0.15, 0.1, i * 0.06); },
    breath(inhale) { beep(inhale ? 300 : 200, "sine", 0.4, 0.08, 0); },
  };
}

/* ─── CSS ───────────────────────────────────────────────────────────────────── */
const CSS = `
  @import url('${FONT_LINK}');
  * { box-sizing: border-box; }
  body { margin: 0; font-family: 'Nunito', sans-serif; }
  @keyframes sway    { 0%,100%{ transform:rotate(-5deg) } 50%{ transform:rotate(5deg) } }
  @keyframes swayBig { 0%,100%{ transform:rotate(-3deg) scale(1) } 50%{ transform:rotate(3deg) scale(1.04) } }
  @keyframes float   { 0%,100%{ transform:translateY(0) } 50%{ transform:translateY(-6px) } }
  @keyframes pop     { 0%{ transform:scale(0.6); opacity:0 } 70%{ transform:scale(1.1) } 100%{ transform:scale(1); opacity:1 } }
  @keyframes slideDown { from{ transform:translateY(-14px); opacity:0 } to{ transform:translateY(0); opacity:1 } }
  @keyframes coinPop { 0%,100%{ transform:translateY(0) } 50%{ transform:translateY(-4px) } }
  @keyframes twinkle { 0%,100%{ opacity:0.2 } 50%{ opacity:1 } }
  .sway    { animation: sway    2.8s ease-in-out infinite; }
  .swayBig { animation: swayBig 3.2s ease-in-out infinite; }
  button { cursor:pointer; font-family:'Baloo 2',cursive; }
  button:active { transform:scale(0.96); }
`;

/* ═══════════════════════════════════════════════════════════════════════════════
   DISCLAIMER SCREEN
═══════════════════════════════════════════════════════════════════════════════ */
function Disclaimer({ onAccept }) {
  const [c1, setC1] = useState(false);
  const [c2, setC2] = useState(false);
  const ready = c1 && c2;

  return (
    <div style={{ minHeight:"100vh", background:"linear-gradient(160deg,#e8f5e9,#f1f8e9,#e0f7fa)", display:"flex", alignItems:"center", justifyContent:"center", padding:20 }}>
      <div style={{ maxWidth:460, width:"100%", background:"#fff", borderRadius:28, boxShadow:"0 8px 48px rgba(60,120,60,0.15)", padding:"32px 28px", animation:"pop 0.5s ease" }}>

        <div style={{ textAlign:"center", marginBottom:24 }}>
          <div style={{ fontSize:54 }}>🌿</div>
          <h1 style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:26, color:"#2d5a27", margin:"8px 0 4px" }}>Welcome to Step Garden</h1>
          <p style={{ fontSize:13, color:"#81c784", fontWeight:600, margin:0 }}>A gentle note before you begin</p>
        </div>

        <div style={{ background:"#f9fbe7", borderRadius:18, padding:"18px 20px", marginBottom:20, border:"1.5px solid #c5e1a5" }}>
          <p style={{ fontSize:14, color:"#33691e", lineHeight:1.75, margin:"0 0 12px" }}>
            This app is <strong>not</strong> intended to encourage or promote any form of disordered eating or unhealthy behaviors. It is a gentle space for movement, hydration, and self-care.
          </p>
          <hr style={{ border:"none", borderTop:"1px solid #dcedc8", margin:"12px 0" }} />
          <p style={{ fontSize:14, color:"#33691e", lineHeight:1.75, margin:"0 0 12px" }}>
            I believe with my whole heart that <strong>every person has full autonomy over their body and the choices they make in their life.</strong> My only hope is that you choose health and happiness — because that is what I wish for you. 💚
          </p>
          <hr style={{ border:"none", borderTop:"1px solid #dcedc8", margin:"12px 0" }} />
          <p style={{ fontSize:14, color:"#33691e", lineHeight:1.75, margin:0 }}>
            Everyone has a beautiful garden in their heart. We all grow a little differently — but we are all still <strong>deserving of love,</strong> especially the love that comes from one's self. 🌸
          </p>
        </div>

        {[
          { val:c1, set:setC1, text:"I promise to take good care of myself — my body, my mind, and my spirit. I will treat myself with kindness and patience as I grow. 🌱" },
          { val:c2, set:setC2, text:"I promise to take good care of those around me, because life is about people. We all bloom in our own time, and I will celebrate that in myself and others. 🌸" },
        ].map(({ val, set, text }, i) => (
          <div key={i} onClick={() => set(v => !v)} style={{ display:"flex", gap:14, alignItems:"flex-start", cursor:"pointer", padding:"14px 16px", marginBottom:12, background:val?"#e8f5e9":"#fafafa", borderRadius:14, border:`2px solid ${val?"#43a047":"#e0e0e0"}`, transition:"all 0.25s" }}>
            <div style={{ width:24, height:24, borderRadius:8, border:`2.5px solid ${val?"#43a047":"#bdbdbd"}`, background:val?"#43a047":"#fff", display:"flex", alignItems:"center", justifyContent:"center", flexShrink:0, marginTop:1 }}>
              {val && <span style={{ color:"#fff", fontSize:14, lineHeight:1 }}>✓</span>}
            </div>
            <p style={{ fontSize:13, color:val?"#2d5a27":"#666", lineHeight:1.65, margin:0, fontWeight:val?700:400 }}>{text}</p>
          </div>
        ))}

        <button
          onClick={() => ready && onAccept()}
          style={{ width:"100%", padding:16, borderRadius:16, background:ready?"linear-gradient(135deg,#66bb6a,#2e7d32)":"#e0e0e0", border:"none", color:ready?"#fff":"#aaa", fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:17, marginTop:4, transition:"all 0.3s", boxShadow:ready?"0 4px 20px rgba(60,150,60,0.3)":"none" }}
        >
          {ready ? "Enter My Garden 🌿" : "Please check both boxes to continue"}
        </button>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════════════════
   MEDITATION SCREEN
═══════════════════════════════════════════════════════════════════════════════ */
function Meditation({ sky, onClose, snd }) {
  const [phase, setPhase] = useState("intro");   // intro | ready | breathing | done
  const [mins, setMins] = useState(5);
  const [bPhase, setBPhase] = useState("inhale");
  const [bCount, setBCount] = useState(0);
  const [elapsed, setElapsed] = useState(0);
  const [big, setBig] = useState(false);
  const tickRef = useRef(null);
  const breathRef = useRef(null);

  const INHALE = 4, HOLD = 2, EXHALE = 6, CYCLE = 12;
  const total = mins * 60;

  useEffect(() => {
    if (phase !== "breathing") return;
    let t = 0;
    tickRef.current = setInterval(() => {
      t++;
      setElapsed(t);
      if (t >= total) {
        clearInterval(tickRef.current);
        clearInterval(breathRef.current);
        setPhase("done");
      }
    }, 1000);

    function runCycle() {
      setBPhase("inhale"); setBig(true); snd.breath(true);
      setTimeout(() => setBPhase("hold"), INHALE * 1000);
      setTimeout(() => { setBPhase("exhale"); setBig(false); snd.breath(false); }, (INHALE + HOLD) * 1000);
      setTimeout(() => setBCount(c => c + 1), CYCLE * 1000);
    }
    runCycle();
    breathRef.current = setInterval(runCycle, CYCLE * 1000);

    return () => { clearInterval(tickRef.current); clearInterval(breathRef.current); };
  }, [phase]);

  const remaining = total - elapsed;
  const mm = String(Math.floor(remaining / 60)).padStart(2, "0");
  const ss = String(remaining % 60).padStart(2, "0");
  const pct = elapsed / total;
  const R = 88;
  const circ = 2 * Math.PI * R;
  const bColor = bPhase === "inhale" ? "#81c784" : bPhase === "hold" ? "#64b5f6" : "#ffb74d";
  const bLabel = bPhase === "inhale" ? "Breathe In" : bPhase === "hold" ? "Hold" : "Breathe Out";
  const bHint  = bPhase === "inhale" ? "Fill your belly first, then your chest." : bPhase === "hold" ? "Hold gently. Feel the stillness." : "Let it all go slowly. Belly falls first.";
  const bDur   = bPhase === "inhale" ? INHALE : bPhase === "hold" ? HOLD : EXHALE;

  return (
    <div style={{ position:"fixed", inset:0, zIndex:300, background:`linear-gradient(180deg,${sky.sky1},${sky.sky2})`, display:"flex", flexDirection:"column", alignItems:"center", justifyContent:"center", padding:24, fontFamily:"'Nunito',sans-serif" }}>
      <button onClick={onClose} style={{ position:"absolute", top:18, right:18, background:"rgba(255,255,255,0.25)", border:"none", borderRadius:99, padding:"8px 16px", color:"#fff", fontWeight:700, fontSize:13 }}>✕ Close</button>

      {phase === "intro" && (
        <div style={{ maxWidth:420, width:"100%", textAlign:"center" }}>
          <div style={{ fontSize:56, marginBottom:10 }}>🧘</div>
          <h2 style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:26, color:"#fff", margin:"0 0 10px" }}>Garden Meditation</h2>
          <p style={{ color:"rgba(255,255,255,0.9)", fontSize:14, lineHeight:1.7, marginBottom:20 }}>Diaphragmatic breathing calms your nervous system, reduces stress, and connects you to the present moment.</p>
          <div style={{ background:"rgba(255,255,255,0.2)", borderRadius:18, padding:18, marginBottom:20, textAlign:"left" }}>
            <p style={{ color:"#fff", fontWeight:700, fontSize:13, margin:"0 0 12px", textAlign:"center" }}>How to breathe with your diaphragm</p>
            {[["1","Place one hand on your chest, one on your belly.","👋"],["2","As you inhale, your belly rises — not your chest.","🫁"],["3","Exhale slowly and completely. Feel your belly fall.","🌬️"],["4","Your chest stays mostly still throughout.","✨"]].map(([n,t,e]) => (
              <div key={n} style={{ display:"flex", gap:10, alignItems:"flex-start", marginBottom:10 }}>
                <div style={{ width:24, height:24, borderRadius:"50%", background:"rgba(255,255,255,0.3)", display:"flex", alignItems:"center", justifyContent:"center", color:"#fff", fontWeight:800, fontSize:12, flexShrink:0 }}>{n}</div>
                <div style={{ fontSize:13, color:"rgba(255,255,255,0.95)", lineHeight:1.6, paddingTop:3 }}>{e} {t}</div>
              </div>
            ))}
          </div>
          <div style={{ display:"flex", gap:10, justifyContent:"center", marginBottom:22 }}>
            {[5,10,15].map(d => (
              <button key={d} onClick={() => setMins(d)} style={{ padding:"10px 22px", borderRadius:99, background:mins===d?"#fff":"rgba(255,255,255,0.25)", border:"none", color:mins===d?"#2d5a27":"#fff", fontWeight:800, fontSize:15 }}>{d} min</button>
            ))}
          </div>
          <button onClick={() => setPhase("ready")} style={{ width:"100%", padding:16, borderRadius:16, background:"rgba(255,255,255,0.25)", border:"2px solid rgba(255,255,255,0.6)", color:"#fff", fontWeight:800, fontSize:17 }}>I'm Ready to Begin 🌿</button>
        </div>
      )}

      {phase === "ready" && (
        <div style={{ textAlign:"center", maxWidth:360 }}>
          <div style={{ fontSize:64, marginBottom:14 }}>🌸</div>
          <h2 style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:24, color:"#fff", margin:"0 0 12px" }}>Find a comfortable position.</h2>
          <p style={{ color:"rgba(255,255,255,0.85)", fontSize:14, lineHeight:1.7, marginBottom:30 }}>Sit or lie down. Place one hand on your chest, one on your belly. Close your eyes if you wish.</p>
          <button onClick={() => setPhase("breathing")} style={{ padding:"16px 40px", borderRadius:99, background:"#fff", border:"none", color:"#2d5a27", fontWeight:800, fontSize:18 }}>Begin 🌬️</button>
        </div>
      )}

      {phase === "breathing" && (
        <div style={{ textAlign:"center", width:"100%", maxWidth:360 }}>
          <div style={{ fontSize:13, color:"rgba(255,255,255,0.7)", marginBottom:14, fontWeight:600 }}>{mm}:{ss} remaining</div>
          <div style={{ display:"flex", justifyContent:"center", marginBottom:10 }}>
            <svg viewBox="0 0 200 200" width="200" height="200">
              <circle cx="100" cy="100" r={R} fill="none" stroke="rgba(255,255,255,0.15)" strokeWidth="6"/>
              <circle cx="100" cy="100" r={R} fill="none" stroke="rgba(255,255,255,0.6)" strokeWidth="6"
                strokeDasharray={String(circ)} strokeDashoffset={String(circ * (1 - pct))}
                strokeLinecap="round" transform="rotate(-90 100 100)"
                style={{ transition:"stroke-dashoffset 1s linear" }}/>
              {[55,42,30].map((r,i) => (
                <circle key={r} cx="100" cy="100" r={r}
                  fill={bColor} opacity={[0.2,0.35,0.65][i]}
                  style={{ transform:`scale(${big ? 1.6 : 1})`, transformOrigin:"100px 100px", transition:`transform ${bDur}s ease-in-out` }}/>
              ))}
            </svg>
          </div>
          <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:28, color:"#fff", margin:"0 0 6px" }}>{bLabel}</div>
          <div style={{ fontSize:13, color:"rgba(255,255,255,0.85)", lineHeight:1.6, marginBottom:18, minHeight:40 }}>{bHint}</div>
          <div style={{ display:"flex", gap:14, justifyContent:"center" }}>
            {[["🫃","Belly", bPhase!=="hold"],["🫀","Chest",false]].map(([e,l,active]) => (
              <div key={l} style={{ background:active?"rgba(255,255,255,0.25)":"rgba(255,255,255,0.1)", borderRadius:12, padding:"10px 16px", transition:"all 0.5s" }}>
                <div style={{ fontSize:20 }}>{e}</div>
                <div style={{ fontSize:11, color:"rgba(255,255,255,0.8)", fontWeight:600 }}>{l}</div>
                <div style={{ fontSize:10, color:active?"rgba(255,255,255,0.9)":"rgba(255,255,255,0.4)" }}>{active?(bPhase==="inhale"?"Rising ↑":"Falling ↓"):"Still"}</div>
              </div>
            ))}
          </div>
          <div style={{ marginTop:14, fontSize:11, color:"rgba(255,255,255,0.45)" }}>Breath {bCount + 1}</div>
        </div>
      )}

      {phase === "done" && (
        <div style={{ textAlign:"center", maxWidth:320 }}>
          <div style={{ fontSize:64, marginBottom:14 }}>🌸</div>
          <h2 style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:26, color:"#fff", margin:"0 0 10px" }}>Beautiful. 💚</h2>
          <p style={{ color:"rgba(255,255,255,0.9)", fontSize:14, lineHeight:1.7, marginBottom:8 }}>You just gave yourself {mins} minutes of pure care. Your garden — inside and out — is grateful.</p>
          <p style={{ color:"rgba(255,255,255,0.6)", fontSize:13, marginBottom:28 }}>{bCount} mindful breaths completed</p>
          <button onClick={onClose} style={{ padding:"14px 36px", borderRadius:99, background:"#fff", border:"none", color:"#2d5a27", fontWeight:800, fontSize:16 }}>Return to My Garden 🌿</button>
        </div>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════════════════
   DRAGGABLE GARDEN
═══════════════════════════════════════════════════════════════════════════════ */
function Garden({ items, onMove, skyData }) {
  const ref = useRef(null);
  const drag = useRef(null);

  function startDrag(e, id) {
    e.preventDefault();
    drag.current = id;
    function onMove2(ev) {
      if (!drag.current || !ref.current) return;
      const rect = ref.current.getBoundingClientRect();
      const cx = ev.touches ? ev.touches[0].clientX : ev.clientX;
      const cy = ev.touches ? ev.touches[0].clientY : ev.clientY;
      const px = Math.max(5, Math.min(92, ((cx - rect.left) / rect.width) * 100));
      const py = Math.max(8, Math.min(88, ((cy - rect.top) / rect.height) * 100));
      onMove(drag.current, px, py);
    }
    function onUp() {
      drag.current = null;
      window.removeEventListener("mousemove", onMove2);
      window.removeEventListener("mouseup", onUp);
      window.removeEventListener("touchmove", onMove2);
      window.removeEventListener("touchend", onUp);
    }
    window.addEventListener("mousemove", onMove2);
    window.addEventListener("mouseup", onUp);
    window.addEventListener("touchmove", onMove2, { passive:false });
    window.addEventListener("touchend", onUp);
  }

  return (
    <div ref={ref} style={{ position:"relative", width:"100%", paddingBottom:"68%", borderRadius:22, overflow:"hidden", background:`linear-gradient(180deg,${skyData.gnd1},${skyData.gnd2})`, boxShadow:"0 4px 28px rgba(0,0,0,0.14)", userSelect:"none" }}>
      {/* Ground dots */}
      {Array.from({length:18}).map((_,i) => (
        <div key={i} style={{ position:"absolute", width:5, height:5, borderRadius:"50%", background:"rgba(0,0,0,0.07)", left:`${(i*19+7)%90}%`, top:`${(i*23+12)%85}%`, pointerEvents:"none" }}/>
      ))}
      {/* Swaying grass */}
      {Array.from({length:12}).map((_,i) => (
        <div key={i} className="sway" style={{ position:"absolute", fontSize:15, left:`${(i*15+4)%88}%`, top:`${(i*17+5)%78}%`, opacity:0.3, animationDelay:`${i*0.2}s`, pointerEvents:"none" }}>🌾</div>
      ))}
      {/* Night stars */}
      {skyData.night && Array.from({length:20}).map((_,i) => (
        <div key={i} style={{ position:"absolute", width:3, height:3, borderRadius:"50%", background:"#fff", left:`${(i*17+4)%94}%`, top:`${(i*11+1)%45}%`, opacity:0.6, animation:`twinkle ${1.5+i*0.2}s ease-in-out infinite`, animationDelay:`${i*0.15}s`, pointerEvents:"none" }}/>
      ))}
      {/* Garden items */}
      {items.map(item => {
        const isPlant = !!item.plantType;
        const def = isPlant ? PLANTS[item.plantType] : DECOS.find(d => d.id === item.decoId);
        if (!def) return null;
        const icon = isPlant ? def.em[3] : def.em;
        const sz = isPlant ? def.sz : 30;
        const anim = isPlant && def.sz >= 40 ? "swayBig" : "sway";
        return (
          <div key={item.id}
            onMouseDown={e => startDrag(e, item.id)}
            onTouchStart={e => startDrag(e, item.id)}
            className={anim}
            style={{ position:"absolute", left:`${item.px}%`, top:`${item.py}%`, transform:"translate(-50%,-50%)", fontSize:sz, cursor:"grab", filter:"drop-shadow(0 3px 6px rgba(0,0,0,0.18))", zIndex:Math.round(item.py), animationDelay:`${Math.random()*2}s` }}>
            {icon}
          </div>
        );
      })}
      {items.length === 0 && (
        <div style={{ position:"absolute", inset:0, display:"flex", flexDirection:"column", alignItems:"center", justifyContent:"center", gap:8, pointerEvents:"none" }}>
          <div style={{ fontSize:32, opacity:0.45 }}>🌱</div>
          <div style={{ fontSize:12, color:"rgba(255,255,255,0.7)", fontWeight:600, textAlign:"center", padding:"0 20px" }}>Transplant plants from the Nursery to see them grow here!</div>
        </div>
      )}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════════════════
   POT CARD
═══════════════════════════════════════════════════════════════════════════════ */
function PotCard({ pot, onTransplant, onRemove, ready }) {
  const p = PLANTS[pot.type];
  const g = plantGrowth(pot);
  const stage = plantStage(g);
  const sPct = Math.min(pot.stepsAcc / p.steps, 1);
  const wPct = Math.min(pot.waterAcc / p.water, 1);
  const behind = sPct < wPct ? "steps" : wPct < sPct ? "water" : null;

  return (
    <div style={{ background:ready?"#f1f8e9":"#fafff8", borderRadius:14, border:ready?"2px solid #43a047":"1.5px solid #e8f5e9", padding:"12px 14px", marginBottom:10, display:"flex", alignItems:"center", gap:12 }}>
      <div style={{ flexShrink:0 }}>
        <svg viewBox="0 0 60 70" width="50" height="58">
          <rect x="18" y="44" width="24" height="5" rx="2" fill="#A0522D"/>
          <path d="M12 49 L18 70 L42 70 L48 49 Z" fill="#CD853F"/>
          <ellipse cx="30" cy="49" rx="18" ry="5" fill="#A0522D"/>
          <ellipse cx="30" cy="44" rx="16" ry="4" fill="#7a4a2a"/>
          <text x="30" y="41" textAnchor="middle" fontSize="21">{p.em[stage]}</text>
        </svg>
      </div>
      <div style={{ flex:1, minWidth:0 }}>
        <div style={{ display:"flex", justifyContent:"space-between", marginBottom:6 }}>
          <span style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:14, color:"#2d5a27" }}>{p.name}</span>
          <span style={{ fontSize:11, color:"#81c784" }}>Stage {stage+1}/4</span>
        </div>
        {[["👟","Steps", pot.stepsAcc, p.steps, sPct, behind==="steps","#43a047","#e8f5e9"],
          ["💧","Water", pot.waterAcc, p.water, wPct, behind==="water","#1976d2","#e3f2fd"]].map(([ico,lbl,acc,max,pct,warn,barClr,bgClr]) => (
          <div key={lbl} style={{ marginBottom:5 }}>
            <div style={{ display:"flex", justifyContent:"space-between", fontSize:10, color:warn?"#e65100":"#78909c", marginBottom:2 }}>
              <span>{ico} {lbl}</span>
              <span>{typeof acc === "number" ? acc.toLocaleString() : acc} / {typeof max === "number" ? max.toLocaleString() : max}{warn?" ← needs more":""}</span>
            </div>
            <div style={{ height:5, background:bgClr, borderRadius:99, overflow:"hidden" }}>
              <div style={{ height:"100%", width:`${Math.round(pct*100)}%`, background:barClr, borderRadius:99, transition:"width 0.4s" }}/>
            </div>
          </div>
        ))}
        {ready && <button onClick={onTransplant} style={{ width:"100%", marginTop:4, padding:"8px", borderRadius:10, background:"#43a047", border:"none", color:"#fff", fontWeight:800, fontSize:13 }}>🌳 Plant in Garden</button>}
      </div>
      <button onClick={onRemove} style={{ background:"none", border:"none", color:"#ccc", fontSize:18, padding:4, flexShrink:0 }}>×</button>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════════════════
   MAIN APP
═══════════════════════════════════════════════════════════════════════════════ */
export default function App() {
  /* ── accept disclaimer ── */
  const [accepted, setAccepted] = useState(false);

  /* ── navigation ── */
  const [tab, setTab] = useState("nursery");
  const [timeKey, setTimeKey] = useState("day");
  const [meditating, setMeditating] = useState(false);

  /* ── stats ── */
  const [coins, setCoins] = useState(80);
  const [pending, setPending] = useState(4200);   // steps not yet converted
  const syncedSteps = 4200;                        // would come from HealthKit in real app
  const [water, setWater] = useState(0);
  const WATER_GOAL = 8;

  /* ── nursery ── */
  const [pots, setPots] = useState([
    { id:1, type:"daisy",  stepsAcc:0, waterAcc:0 },
    { id:2, type:"cactus", stepsAcc:0, waterAcc:0 },
  ]);
  const [nextId, setNextId] = useState(3);
  const [picking, setPicking] = useState("daisy");

  /* ── garden ── */
  const [items, setItems] = useState([]);

  /* ── health ── */
  const [log, setLog] = useState([{date:"May 29",val:186},{date:"May 31",val:185},{date:"Jun 2",val:184},{date:"Jun 4",val:183}]);
  const [wInput, setWInput] = useState("");

  /* ── toast ── */
  const [toast, setToast] = useState(null);
  const toastTimer = useRef(null);

  /* ── audio ── */
  const snd = useRef(buildAudio()).current;

  /* ── affirmation ── */
  const [affirm] = useState(AFFIRMATIONS[Math.floor(Math.random() * AFFIRMATIONS.length)]);
  const [showAffirm, setShowAffirm] = useState(true);

  const skyData = SKY[timeKey];

  /* helpers */
  function toast2(msg, em = "🌱") {
    setToast({ msg, em });
    clearTimeout(toastTimer.current);
    toastTimer.current = setTimeout(() => setToast(null), 2800);
  }

  function updPots(addSteps, addWater) {
    setPots(prev => prev.map(pot => {
      const updated = { ...pot, stepsAcc: pot.stepsAcc + addSteps, waterAcc: pot.waterAcc + addWater };
      return updated;
    }));
  }

  /* ── actions ── */
  function convertSteps() {
    if (pending < 100) { toast2("Walk more to earn coins!", "👟"); return; }
    const earned = Math.floor(pending / 100);
    setCoins(c => c + earned);
    updPots(pending, 0);
    setPending(0);
    snd.coins();
    toast2(`+${earned} coins earned!`, "🪙");
  }

  function addWater() {
    if (water >= WATER_GOAL) { toast2("Daily goal reached! 🎉", "💧"); return; }
    const nw = water + 1;
    setWater(nw);
    updPots(0, 1);
    snd.water();
    toast2(`${nw}/${WATER_GOAL} glasses today`, "💧");
  }

  function startPot() {
    const p = PLANTS[picking];
    if (p.coins > 0 && coins < p.coins) { toast2("Not enough coins!", "🪙"); return; }
    if (p.coins > 0) setCoins(c => c - p.coins);
    snd.plant();
    setPots(prev => [...prev, { id:nextId, type:picking, stepsAcc:0, waterAcc:0 }]);
    setNextId(n => n + 1);
    toast2(`${p.name} seedling started!`, "🌱");
  }

  function transplant(pot) {
    const px = 15 + Math.random() * 70;
    const py = 20 + Math.random() * 60;
    setItems(prev => [...prev, { id:pot.id, plantType:pot.type, px, py }]);
    setPots(prev => prev.filter(p => p.id !== pot.id));
    snd.plant();
    toast2(`${PLANTS[pot.type].name} planted in your garden!`, "🌳");
    setTab("garden");
  }

  function placeDeco(deco) {
    if (coins < deco.cost) { toast2("Not enough coins!", "🪙"); return; }
    setCoins(c => c - deco.cost);
    const px = 15 + Math.random() * 70;
    const py = 20 + Math.random() * 60;
    setItems(prev => [...prev, { id:Date.now(), decoId:deco.id, px, py }]);
    snd.chime();
    toast2(`${deco.name} placed!`, deco.em);
    setTab("garden");
  }

  const moveItem = useCallback((id, px, py) => {
    setItems(prev => prev.map(it => it.id === id ? { ...it, px, py } : it));
  }, []);

  function logWeight() {
    const v = parseFloat(wInput);
    if (isNaN(v)) return;
    const d = new Date().toLocaleDateString("en-US", { month:"short", day:"numeric" });
    setLog(prev => [...prev, { date:d, val:v }]);
    setWInput("");
    toast2("Weight logged!", "⚖️");
  }

  const readyPots  = pots.filter(p => plantGrowth(p) >= 1);
  const growingPots = pots.filter(p => plantGrowth(p) < 1);

  /* ── screens ── */
  if (!accepted) return <><style>{CSS}</style><Disclaimer onAccept={() => setAccepted(true)} /></>;
  if (meditating) return <><style>{CSS}</style><Meditation sky={skyData} onClose={() => setMeditating(false)} snd={snd} /></>;

  /* ── shared style pieces ── */
  const cardBase = { background:"rgba(255,255,255,0.96)", borderRadius:24, boxShadow:"0 4px 32px rgba(60,120,60,0.11)", overflow:"hidden" };
  const tabBtnStyle = (key) => ({ flex:1, padding:"10px 2px 8px", fontFamily:"'Baloo 2',cursive", fontWeight:tab===key?800:600, fontSize:10, background:tab===key?"#fff":"transparent", color:tab===key?"#2d5a27":"#81c784", border:"none", borderBottom:tab===key?"2.5px solid #43a047":"2.5px solid transparent", display:"flex", flexDirection:"column", alignItems:"center", gap:2, transition:"all 0.18s" });

  return (
    <>
      <style>{CSS}</style>
      <div style={{ fontFamily:"'Nunito',sans-serif", minHeight:"100vh", background:`linear-gradient(180deg,${skyData.sky1} 0%,${skyData.sky2} 35%,${skyData.gnd1} 35%)`, display:"flex", flexDirection:"column", alignItems:"center", padding:"12px 12px 60px", transition:"background 1.2s" }}>

        {/* Sky decorations */}
        <div style={{ position:"fixed", top:0, left:0, right:0, height:"35vh", pointerEvents:"none", zIndex:0, overflow:"hidden" }}>
          <div className="float" style={{ position:"absolute", fontSize:28, right:"12%", top:"12%" }}>{skyData.sun}</div>
          {timeKey === "day" && <>
            <div className="float" style={{ position:"absolute", fontSize:22, left:"18%", top:"20%", animationDelay:"1s", opacity:0.85 }}>☁️</div>
            <div className="float" style={{ position:"absolute", fontSize:16, left:"52%", top:"10%", animationDelay:"2s", opacity:0.7 }}>☁️</div>
            <div className="float" style={{ position:"absolute", fontSize:15, right:"30%", top:"28%", animationDelay:"0.5s" }}>🦋</div>
            <div className="float" style={{ position:"absolute", fontSize:14, left:"8%",  top:"35%", animationDelay:"1.5s" }}>🐦</div>
          </>}
          {timeKey === "night" && Array.from({length:18}).map((_,i) => (
            <div key={i} style={{ position:"absolute", fontSize:9, left:`${(i*17+3)%94}%`, top:`${(i*11+2)%88}%`, color:"#fff", animation:`twinkle ${1.5+i*0.3}s ease-in-out infinite`, animationDelay:`${i*0.15}s` }}>★</div>
          ))}
          {timeKey === "sunset" && <div className="float" style={{ position:"absolute", fontSize:16, left:"14%", top:"26%", animationDelay:"0.8s" }}>🦅</div>}
        </div>

        {/* Toast */}
        {toast && (
          <div style={{ position:"fixed", top:18, left:"50%", transform:"translateX(-50%)", zIndex:999, background:"#fff", borderRadius:50, padding:"10px 22px", boxShadow:"0 4px 24px rgba(0,0,0,0.12)", fontFamily:"'Baloo 2',cursive", fontWeight:700, fontSize:14, color:"#2d5a27", display:"flex", alignItems:"center", gap:8, animation:"slideDown 0.25s ease", whiteSpace:"nowrap" }}>
            <span>{toast.em}</span>{toast.msg}
          </div>
        )}

        <div style={{ width:"100%", maxWidth:480, position:"relative", zIndex:1 }}>

          {/* Affirmation */}
          {showAffirm && (
            <div style={{ background:"rgba(255,255,255,0.88)", borderRadius:16, padding:"12px 16px", marginBottom:10, display:"flex", gap:10, alignItems:"flex-start", boxShadow:"0 2px 12px rgba(80,160,80,0.1)", animation:"slideDown 0.3s ease" }}>
              <span style={{ fontSize:16, marginTop:2 }}>✨</span>
              <div style={{ flex:1 }}>
                <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:700, fontSize:10, color:"#1b5e20", letterSpacing:"0.07em", marginBottom:2 }}>TODAY'S AFFIRMATION</div>
                <div style={{ fontSize:12, color:"#33691e", lineHeight:1.55 }}>{affirm}</div>
              </div>
              <button onClick={() => setShowAffirm(false)} style={{ background:"none", border:"none", color:"#a5d6a7", fontSize:16, padding:0 }}>×</button>
            </div>
          )}

          {/* Header */}
          <div style={{ background:"rgba(255,255,255,0.92)", borderRadius:20, padding:"12px 16px", marginBottom:10, boxShadow:"0 2px 16px rgba(60,120,60,0.1)", display:"flex", justifyContent:"space-between", alignItems:"center", flexWrap:"wrap", gap:8 }}>
            <div>
              <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:20, color:"#2d5a27" }}>Step Garden 🌿</div>
              <div style={{ fontSize:11, color:"#81c784" }}>Walk · Drink · Grow</div>
            </div>
            <div style={{ display:"flex", gap:10, alignItems:"center" }}>
              <div style={{ textAlign:"center" }}>
                <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:16, color:"#f9a825", animation:"coinPop 2s ease-in-out infinite" }}>🪙 {coins}</div>
                <div style={{ fontSize:9, color:"#aaa" }}>coins</div>
              </div>
              <div style={{ textAlign:"center" }}>
                <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:16, color:"#43a047" }}>👟 {syncedSteps.toLocaleString()}</div>
                <div style={{ fontSize:9, color:"#aaa" }}>steps</div>
              </div>
              <button onClick={() => setMeditating(true)} style={{ padding:"7px 12px", borderRadius:99, background:"linear-gradient(135deg,#a5d6a7,#4db6ac)", border:"none", color:"#fff", fontWeight:700, fontSize:12 }}>🧘 Meditate</button>
            </div>
          </div>

          {/* Time mode */}
          <div style={{ display:"flex", gap:6, marginBottom:10, justifyContent:"center", flexWrap:"wrap" }}>
            {Object.entries(SKY).map(([key, info]) => (
              <button key={key} onClick={() => setTimeKey(key)} style={{ padding:"6px 12px", borderRadius:99, background:timeKey===key?"rgba(255,255,255,0.95)":"rgba(255,255,255,0.38)", border:"none", fontWeight:700, fontSize:11, color:timeKey===key?"#2d5a27":"rgba(255,255,255,0.95)", transition:"all 0.2s" }}>
                {info.sun} {key.charAt(0).toUpperCase()+key.slice(1)}
              </button>
            ))}
          </div>

          {/* Main card */}
          <div style={cardBase}>

            {/* Tabs */}
            <div style={{ display:"flex", borderBottom:"1.5px solid #f1f8e9", background:"#fafff8" }}>
              {[["nursery","🪴","Nursery"],["garden","🌳","Garden"],["coins","🪙","Coins"],["shop","🛒","Shop"],["health","💪","Health"]].map(([key,icon,label]) => (
                <button key={key} onClick={() => setTab(key)} style={tabBtnStyle(key)}>
                  <span style={{ fontSize:16 }}>{icon}</span>
                  {label}
                  {key==="nursery" && readyPots.length > 0 && <span style={{ background:"#e53935", color:"#fff", borderRadius:99, fontSize:8, padding:"0 5px", fontWeight:800, lineHeight:1.6 }}>{readyPots.length}</span>}
                </button>
              ))}
            </div>

            {/* ── NURSERY ── */}
            {tab === "nursery" && (
              <div style={{ padding:16 }}>
                {/* Water */}
                <div style={{ background:"#e3f2fd", borderRadius:14, padding:"12px 14px", marginBottom:14 }}>
                  <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center", marginBottom:8 }}>
                    <div>
                      <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:700, fontSize:13, color:"#1565c0" }}>💧 Water your plants</div>
                      <div style={{ fontSize:11, color:"#42a5f5" }}>Each glass waters all nursery pots</div>
                    </div>
                    <button onClick={addWater} style={{ padding:"8px 14px", borderRadius:10, background:"#1976d2", border:"none", color:"#fff", fontWeight:700, fontSize:12 }}>+ Glass 💧</button>
                  </div>
                  <div style={{ display:"flex", gap:4 }}>
                    {Array.from({length:WATER_GOAL}).map((_,i) => (
                      <div key={i} style={{ flex:1, height:20, borderRadius:5, background:i<water?"#1976d2":"#bbdefb", transition:"background 0.3s", display:"flex", alignItems:"center", justifyContent:"center", fontSize:10 }}>{i<water?"💧":""}</div>
                    ))}
                  </div>
                  <div style={{ fontSize:11, color:"#1565c0", marginTop:5, fontWeight:600 }}>{water}/{WATER_GOAL} glasses today{water>=WATER_GOAL?" · Goal reached! 🎉":""}</div>
                </div>

                {/* Steps info */}
                <div style={{ background:"#f1f8e9", borderRadius:14, padding:"10px 14px", marginBottom:14, display:"flex", alignItems:"center", gap:10 }}>
                  <span style={{ fontSize:22 }}>👟</span>
                  <div>
                    <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:700, fontSize:13, color:"#388e3c" }}>{syncedSteps.toLocaleString()} steps from iPhone</div>
                    <div style={{ fontSize:11, color:"#81c784" }}>Go to the Coins tab to convert steps → coins & plant food</div>
                  </div>
                </div>

                {readyPots.length > 0 && (
                  <div style={{ marginBottom:14 }}>
                    <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:13, color:"#2d5a27", marginBottom:8 }}>✅ Ready to plant ({readyPots.length})</div>
                    {readyPots.map(pot => <PotCard key={pot.id} pot={pot} ready onTransplant={() => transplant(pot)} onRemove={() => setPots(p => p.filter(x => x.id !== pot.id))} />)}
                  </div>
                )}

                {growingPots.length > 0 && (
                  <div style={{ marginBottom:14 }}>
                    <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:700, fontSize:12, color:"#81c784", marginBottom:8 }}>🌱 Growing ({growingPots.length})</div>
                    {growingPots.map(pot => <PotCard key={pot.id} pot={pot} ready={false} onRemove={() => setPots(p => p.filter(x => x.id !== pot.id))} />)}
                  </div>
                )}

                {/* Start new pot */}
                <div style={{ background:"#f9fbe7", borderRadius:14, padding:14, border:"1.5px dashed #c5e1a5" }}>
                  <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:700, fontSize:13, color:"#558b2f", marginBottom:10 }}>🌱 Start a new pot</div>
                  <div style={{ display:"grid", gridTemplateColumns:"repeat(4,1fr)", gap:6, marginBottom:10 }}>
                    {Object.entries(PLANTS).map(([key,p]) => (
                      <button key={key} onClick={() => setPicking(key)} style={{ padding:"8px 4px", borderRadius:10, background:picking===key?"#c8e6c9":"#fff", border:picking===key?"2px solid #43a047":"1.5px solid #e8f5e9", display:"flex", flexDirection:"column", alignItems:"center", gap:2 }}>
                        <span style={{ fontSize:18 }}>{p.em[3]}</span>
                        <span style={{ fontSize:9, fontFamily:"'Baloo 2',cursive", fontWeight:700, color:"#388e3c" }}>{p.name}</span>
                        {p.coins > 0 && <span style={{ fontSize:9, color:"#f9a825", fontWeight:700 }}>🪙{p.coins}</span>}
                      </button>
                    ))}
                  </div>
                  <div style={{ fontSize:11, color:"#8d9e7a", marginBottom:10, fontStyle:"italic" }}>{PLANTS[picking].desc} · 👟{PLANTS[picking].steps.toLocaleString()} steps · 💧{PLANTS[picking].water} glasses</div>
                  <button onClick={startPot} style={{ width:"100%", padding:10, borderRadius:12, background:"#43a047", border:"none", color:"#fff", fontWeight:800, fontSize:14 }}>
                    Plant {PLANTS[picking].name} {PLANTS[picking].coins > 0 ? `· 🪙${PLANTS[picking].coins}` : "· Free"}
                  </button>
                </div>
              </div>
            )}

            {/* ── GARDEN ── */}
            {tab === "garden" && (
              <div style={{ padding:16 }}>
                <div style={{ fontSize:12, color:"#81c784", marginBottom:10, textAlign:"center" }}>✨ Drag your plants and decorations anywhere!</div>
                <Garden items={items} onMove={moveItem} skyData={skyData} />
                <div style={{ marginTop:10, fontSize:11, color:"#aaa", textAlign:"center" }}>{items.length} item{items.length !== 1 ? "s" : ""} · Everything sways gently in the breeze 🌿</div>
              </div>
            )}

            {/* ── COINS ── */}
            {tab === "coins" && (
              <div style={{ padding:16 }}>
                <div style={{ background:"linear-gradient(135deg,#fff8e1,#fff3cd)", borderRadius:18, padding:20, marginBottom:16, textAlign:"center", border:"1.5px solid #ffe082" }}>
                  <div style={{ fontSize:44, marginBottom:6, animation:"coinPop 1.5s ease-in-out infinite" }}>🪙</div>
                  <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:32, color:"#f57f17" }}>{coins} coins</div>
                  <div style={{ fontSize:12, color:"#f9a825", marginTop:4 }}>Spend on seeds and decorations in the Shop</div>
                </div>
                <div style={{ background:"#f1f8e9", borderRadius:16, padding:16, marginBottom:14 }}>
                  <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:15, color:"#2d5a27", marginBottom:4 }}>Convert steps to coins</div>
                  <div style={{ fontSize:12, color:"#81c784", marginBottom:14 }}>Every 100 steps = 1 coin. Converting also feeds your nursery plants!</div>
                  <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:12, marginBottom:16 }}>
                    <div style={{ background:"#fff", borderRadius:12, padding:12, textAlign:"center" }}>
                      <div style={{ fontSize:11, color:"#aaa", marginBottom:2 }}>Steps to convert</div>
                      <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:22, color:"#43a047" }}>👟 {pending.toLocaleString()}</div>
                    </div>
                    <div style={{ background:"#fff", borderRadius:12, padding:12, textAlign:"center" }}>
                      <div style={{ fontSize:11, color:"#aaa", marginBottom:2 }}>You will earn</div>
                      <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:22, color:"#f9a825" }}>🪙 {Math.floor(pending/100)}</div>
                    </div>
                  </div>
                  <button onClick={convertSteps} style={{ width:"100%", padding:14, borderRadius:14, background:pending>=100?"linear-gradient(135deg,#ffca28,#ff8f00)":"#e0e0e0", border:"none", color:pending>=100?"#fff":"#aaa", fontWeight:800, fontSize:16, boxShadow:pending>=100?"0 4px 18px rgba(255,143,0,0.3)":"none", transition:"all 0.2s" }}>
                    {pending >= 100 ? `Convert ${pending.toLocaleString()} steps → 🪙${Math.floor(pending/100)}` : "Walk more to convert steps!"}
                  </button>
                  <div style={{ marginTop:12, padding:"10px 12px", background:"rgba(255,255,255,0.6)", borderRadius:10, fontSize:11, color:"#558b2f" }}>
                    💡 Steps sync automatically from your iPhone's Health app — no manual logging needed!
                  </div>
                </div>
                <div style={{ background:"#fff", borderRadius:14, border:"1.5px solid #e8f5e9", padding:14 }}>
                  <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:700, fontSize:13, color:"#2d5a27", marginBottom:10 }}>Earning guide</div>
                  {[["👟","100 steps = 1 coin","Walk daily to earn"],["💧","Log water glasses","Grow plants faster"],["🌿","Rare plants","Take more steps and water to grow"]].map(([e,v,d]) => (
                    <div key={v} style={{ display:"flex", alignItems:"center", gap:12, padding:"8px 0", borderBottom:"0.5px solid #f1f8e9" }}>
                      <div style={{ fontSize:20, width:30, textAlign:"center" }}>{e}</div>
                      <div>
                        <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:700, fontSize:13, color:"#2d5a27" }}>{v}</div>
                        <div style={{ fontSize:11, color:"#81c784" }}>{d}</div>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* ── SHOP ── */}
            {tab === "shop" && (
              <div style={{ padding:16 }}>
                <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:700, fontSize:12, color:"#81c784", marginBottom:12 }}>🪙 {coins} coins available · Decorations drop straight into your garden!</div>
                <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:14, color:"#2d5a27", marginBottom:8 }}>🌱 Seeds</div>
                <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:8, marginBottom:18 }}>
                  {Object.entries(PLANTS).map(([key,p]) => (
                    <div key={key} style={{ background:"#fafff8", borderRadius:14, border:"1.5px solid #e8f5e9", padding:12 }}>
                      <div style={{ display:"flex", justifyContent:"space-between", marginBottom:4 }}>
                        <span style={{ fontSize:26 }}>{p.em[3]}</span>
                        <span style={{ fontSize:9, background:p.sz>=40?"#fff8e1":p.sz>=34?"#e8f5e9":"#f3e5f5", color:p.sz>=40?"#e65100":p.sz>=34?"#2e7d32":"#6a1b9a", borderRadius:99, padding:"2px 8px", fontWeight:800, height:"fit-content", fontFamily:"'Baloo 2',cursive" }}>{p.sz>=40?"large":p.sz>=34?"medium":"small"}</span>
                      </div>
                      <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:13, color:"#2d5a27" }}>{p.name}</div>
                      <div style={{ fontSize:10, color:"#8d9e7a", marginBottom:4 }}>👟{p.steps.toLocaleString()} · 💧{p.water}gl</div>
                      <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:700, fontSize:12, color:p.coins>0?"#f9a825":"#43a047" }}>{p.coins>0?`🪙 ${p.coins}`:"✨ Free"}</div>
                    </div>
                  ))}
                </div>
                <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:14, color:"#2d5a27", marginBottom:8 }}>🏡 Decorations</div>
                <div style={{ display:"grid", gridTemplateColumns:"1fr 1fr", gap:8 }}>
                  {DECOS.map(d => (
                    <div key={d.id} onClick={() => placeDeco(d)} style={{ background:"#fafff8", borderRadius:14, border:"1.5px solid #e8f5e9", padding:12, cursor:coins>=d.cost?"pointer":"not-allowed", opacity:coins>=d.cost?1:0.5, transition:"transform 0.15s" }}>
                      <span style={{ fontSize:26 }}>{d.em}</span>
                      <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:13, color:"#2d5a27", marginTop:4 }}>{d.name}</div>
                      <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:700, fontSize:12, color:"#f9a825" }}>🪙 {d.cost}</div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* ── HEALTH ── */}
            {tab === "health" && (
              <div style={{ padding:16 }}>
                <div style={{ background:"#e3f2fd", borderRadius:16, padding:14, marginBottom:14 }}>
                  <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:14, color:"#1565c0", marginBottom:8 }}>💧 Water Intake</div>
                  <div style={{ display:"flex", gap:4, marginBottom:8 }}>
                    {Array.from({length:WATER_GOAL}).map((_,i) => <div key={i} style={{ flex:1, height:28, borderRadius:6, background:i<water?"#1976d2":"#bbdefb", transition:"background 0.3s", display:"flex", alignItems:"center", justifyContent:"center", fontSize:12 }}>{i<water?"💧":""}</div>)}
                  </div>
                  <div style={{ display:"flex", justifyContent:"space-between", alignItems:"center" }}>
                    <span style={{ fontSize:13, color:"#1565c0", fontWeight:600 }}>{water}/{WATER_GOAL}{water>=WATER_GOAL?" · 🎉 Goal reached!":""}</span>
                    <button onClick={addWater} style={{ padding:"8px 18px", borderRadius:10, background:"#1976d2", border:"none", color:"#fff", fontWeight:700, fontSize:13 }}>+ Glass</button>
                  </div>
                </div>

                <div style={{ background:"#f3e5f5", borderRadius:16, padding:14, marginBottom:14 }}>
                  <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:14, color:"#6a1b9a", marginBottom:10 }}>⚖️ Weight Tracker</div>
                  <div style={{ display:"flex", gap:6, marginBottom:12 }}>
                    <input value={wInput} onChange={e => setWInput(e.target.value)} onKeyDown={e => e.key==="Enter" && logWeight()} placeholder="Enter weight (lbs)" style={{ flex:1, padding:"9px 12px", borderRadius:10, border:"1.5px solid #ce93d8", fontFamily:"'Nunito',sans-serif", fontSize:13, color:"#4a148c", outline:"none" }}/>
                    <button onClick={logWeight} style={{ padding:"9px 16px", borderRadius:10, background:"#8e24aa", border:"none", color:"#fff", fontWeight:700, fontSize:13 }}>Log</button>
                  </div>
                  <div style={{ display:"flex", alignItems:"flex-end", gap:4, height:60 }}>
                    {log.slice(-7).map((w,i,arr) => {
                      const vals = arr.map(x => x.val); const mn = Math.min(...vals)-2, mx = Math.max(...vals)+2;
                      const h = Math.max(8, (1-(w.val-mn)/(mx-mn))*50+10);
                      return (
                        <div key={i} style={{ flex:1, display:"flex", flexDirection:"column", alignItems:"center", gap:2 }}>
                          <div style={{ width:"100%", height:h, background:i===arr.length-1?"#8e24aa":"#ce93d8", borderRadius:"4px 4px 0 0" }}/>
                          <div style={{ fontSize:9, color:"#9c27b0" }}>{w.date.split(" ")[1]}</div>
                        </div>
                      );
                    })}
                  </div>
                  {log.length >= 2 && <div style={{ marginTop:8, fontSize:12, color:"#6a1b9a", fontWeight:600 }}>{log[log.length-1].val < log[0].val ? `📉 Down ${(log[0].val - log[log.length-1].val).toFixed(1)} lbs since you started` : "📊 Keep logging to see your trend"}</div>}
                </div>

                <div style={{ background:"#e8f5e9", borderRadius:16, padding:14 }}>
                  <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:14, color:"#1b5e20", marginBottom:8 }}>👟 Steps Today (from iPhone)</div>
                  <div style={{ fontFamily:"'Baloo 2',cursive", fontWeight:800, fontSize:30, color:"#2e7d32", marginBottom:6 }}>{syncedSteps.toLocaleString()}</div>
                  <div style={{ height:10, background:"#c8e6c9", borderRadius:99, overflow:"hidden", marginBottom:6 }}>
                    <div style={{ height:"100%", width:`${Math.min((syncedSteps/10000)*100,100)}%`, background:"linear-gradient(90deg,#66bb6a,#2e7d32)", borderRadius:99, transition:"width 0.5s" }}/>
                  </div>
                  <div style={{ fontSize:11, color:"#81c784" }}>{syncedSteps>=10000?"🎉 Daily goal reached!":`${(10000-syncedSteps).toLocaleString()} steps to daily goal`}</div>
                </div>
              </div>
            )}

          </div>
        </div>
      </div>
    </>
  );
}
