const screens=[...document.querySelectorAll('.screen')];const nav=[...document.querySelectorAll('nav button')];function showScreen(id){screens.forEach(s=>s.classList.toggle('active',s.id===id));nav.forEach(b=>b.classList.toggle('active',b.dataset.target===id));window.scrollTo({top:0,behavior:'smooth'})}nav.forEach(b=>b.addEventListener('click',()=>showScreen(b.dataset.target)));function openComposer(){document.getElementById('composer').classList.add('open')}function closeComposer(){document.getElementById('composer').classList.remove('open')}document.getElementById('composer').addEventListener('click',e=>{if(e.target.id==='composer')closeComposer()});

if('serviceWorker' in navigator){window.addEventListener('load',()=>navigator.serviceWorker.register('./sw.js').catch(console.warn))}

const ua=navigator.userAgent;const isIOS=/iPhone|iPad|iPod/i.test(ua);const isAndroid=/Android/i.test(ua);const isStandalone=window.matchMedia('(display-mode: standalone)').matches||window.navigator.standalone===true;const deviceName=isIOS?'iPhone/iPad':isAndroid?'Android':'this device';const hour=new Date().getHours();const greeting=hour<5?'Still up, Brother?':hour<12?'Good morning, Brother.':hour<17?'Good afternoon, Brother.':hour<21?'Good evening, Brother.':'Night check-in, Brother.';const title=document.getElementById('greeting')||document.querySelector('#today h1');if(title)title.textContent=greeting;

const context={device:deviceName,timeZone:Intl.DateTimeFormat().resolvedOptions().timeZone,locale:navigator.language,installed:isStandalone,localHour:hour};localStorage.setItem('mogDeviceContext',JSON.stringify(context));const deviceMeta=document.getElementById('deviceMeta');if(deviceMeta)deviceMeta.dataset.device=deviceName;

let deferredPrompt=null;const installCard=document.getElementById('installCard');const installBtn=document.getElementById('installBtn');const installSkip=document.getElementById('installSkip');const deviceCopy=document.getElementById('deviceCopy');const DISMISS_KEY='mogInstallDismissedUntil';

function dismissedForNow(){const until=Number(localStorage.getItem(DISMISS_KEY)||0);return Date.now()<until}function hideInstallCard(){if(installCard)installCard.classList.add('hidden')}function showInstallCard(){if(!installCard||isStandalone||dismissedForNow())return;installCard.classList.remove('hidden');if(deviceCopy){deviceCopy.textContent=isIOS?'Add it to your Home Screen for the full-screen app experience.':isAndroid?'Install Men of God directly on this phone.':'Install Men of God for a full-screen app experience.'}}

window.addEventListener('beforeinstallprompt',e=>{e.preventDefault();deferredPrompt=e;showInstallCard()});

if(installSkip){installSkip.addEventListener('click',()=>{localStorage.setItem(DISMISS_KEY,String(Date.now()+24*60*60*1000));hideInstallCard()})}

if(installBtn){installBtn.addEventListener('click',async()=>{if(isStandalone){hideInstallCard();return}if(isIOS){document.getElementById('iosInstall')?.classList.add('open');return}if(deferredPrompt){deferredPrompt.prompt();const choice=await deferredPrompt.userChoice;deferredPrompt=null;if(choice.outcome==='accepted')hideInstallCard();return}if(isAndroid){alert('Open this page in Chrome, tap the three-dot menu, then choose “Install app” or “Add to Home screen.”');return}alert('Use your browser menu and choose “Install app” or “Add to Home Screen.”')})}

function closeIOSInstall(){document.getElementById('iosInstall')?.classList.remove('open')}window.closeIOSInstall=closeIOSInstall;document.getElementById('iosInstall')?.addEventListener('click',e=>{if(e.target.id==='iosInstall')closeIOSInstall()});

window.addEventListener('appinstalled',()=>{hideInstallCard();localStorage.setItem('mogInstalled','1')});window.addEventListener('load',()=>{if(isStandalone){hideInstallCard()}else{setTimeout(showInstallCard,650)}});