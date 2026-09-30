/* Redro Tools - compatibility build */
(function(){
var tools=[
["CDR -> PDF / EPS","Design","Open a real CDR conversion service for PDF or EPS","CDR"],
["JPG / PNG -> PDF","PDF","Turn images into a printable PDF","PDF"],
["JPG <-> PNG","Images","Convert an image between JPG and PNG","IMG"],
["JSON Formatter","Developer","Format and validate JSON","{}"],
["JSON -> CSV","Developer","Convert JSON arrays to CSV","CSV"],
["Base64 Encoder","Developer","Encode and decode Base64","64"],
["URL Encoder","Developer","Encode and decode URLs","URL"],
["UUID Generator","Developer","Generate random UUIDs","ID"],
["QR Generator","Utilities","Create a QR code","QR"],
["Color Picker","Design","Pick a color and copy its HEX value","HEX"],
["Color Converter","Design","Convert HEX to RGB","RGB"],
["Timestamp Converter","Developer","Convert Unix timestamps and dates","TS"],
["Regex Tester","Developer","Test regular expressions","RX"],
["Markdown Preview","Writing","Preview basic Markdown","MD"],
["Text Diff","Writing","Compare two texts","DIFF"],
["Word Counter","Writing","Count words and characters","123"],
["Image Compressor","Images","Compress an image and download it","IMG"],
["Password Generator","Security","Generate a random password","PW"],
["Hash Generator","Security","Create SHA-256 hashes","SHA"],
["JWT Decoder","Developer","Decode JWT header and payload","JWT"],
["IP/Subnet Calculator","Network","Calculate IPv4 subnet details","IP"],
["Cron Expression Helper","Developer","Explain common cron fields","CRON"]
];

function $(s){return document.querySelector(s);}
function esc(s){
 s=String(s==null?"":s);
 return s.replace(/[&<>"]/g,function(c){return {"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;"}[c];});
}
var grid=$("#tools"),cats=$("#categories"),modal=$("#modal"),view=$("#toolView"),active="All";
var categories=["All"],i,c;
for(i=0;i<tools.length;i++){c=tools[i][1];if(categories.indexOf(c)<0)categories.push(c);}
cats.innerHTML="";
for(i=0;i<categories.length;i++){
 cats.innerHTML+='<button class="cat '+(categories[i]=="All"?"active":"")+'" data-cat="'+esc(categories[i])+'">'+esc(categories[i])+'</button>';
}

function render(){
 var q=($("#search").value||"").toLowerCase(),html="",t;
 for(var j=0;j<tools.length;j++){
  t=tools[j];
  if((active=="All"||t[1]==active)&&((t[0]+" "+t[1]+" "+t[2]).toLowerCase().indexOf(q)>=0)){
   html+='<article class="tool" data-i="'+j+'"><div class="tool-icon">'+esc(t[3])+'</div><h3>'+esc(t[0])+'</h3><p>'+esc(t[2])+'</p><span class="tag">'+esc(t[1])+'</span></article>';
  }
 }
 grid.innerHTML=html||"<p>No tools found.</p>";
}
function bindCategories(e){
 var target=e.target;
 if(!target||target.className.indexOf("cat")<0)return;
 active=target.getAttribute("data-cat");
 var bs=cats.getElementsByTagName("button");
 for(var j=0;j<bs.length;j++)bs[j].className=bs[j]==target?"cat active":"cat";
 render();
}
cats.onclick=bindCategories;
$("#search").oninput=render;

function field(label,id,tag,extra){
 tag=tag||"input"; extra=extra||"";
 return '<div class="field"><label>'+label+'</label><'+tag+' id="'+id+'" '+extra+'></'+tag+'></div>';
}
function shell(title,desc,body){return '<div class="tool-view"><h2>'+esc(title)+'</h2><p class="sub">'+esc(desc)+'</p>'+body+'</div>';}
function out(x){var o=$("#out");if(o)o.textContent=String(x);}
function downloadBlob(blob,name){
 var a=document.createElement("a");
 a.href=URL.createObjectURL(blob);a.download=name;
 document.body.appendChild(a);a.click();document.body.removeChild(a);
 setTimeout(function(){URL.revokeObjectURL(a.href);},1000);
}
function openTool(n){
 var t=tools[n],name=t[0],h="";
 if(name=="CDR -> PDF / EPS"){
  h=shell(name,t[2],'<div class="converter-note"><strong>True vector conversion</strong><p>CDR is a proprietary CorelDRAW format. Redro Tools does not fake conversion by renaming files.</p></div><div class="row"><a class="btn" target="_blank" rel="noopener" href="https://cloudconvert.com/cdr-to-pdf">CDR -> PDF</a><a class="btn secondary" target="_blank" rel="noopener" href="https://cloudconvert.com/cdr-to-eps">CDR -> EPS</a></div><div class="output">Your CDR is sent only to the external converter you choose.</div>');
 }else if(name=="JPG / PNG -> PDF"){
  h=shell(name,t[2],'<div class="field"><label>Images</label><input id="a" type="file" accept="image/jpeg,image/png" multiple></div><button class="btn" id="pdfBtn">Create PDF</button><div id="out" class="output"></div>');
 }else if(name=="JPG <-> PNG"){
  h=shell(name,t[2],'<div class="field"><label>Image</label><input id="a" type="file" accept="image/jpeg,image/png"></div><div class="row"><button class="btn" id="pngBtn">Convert to PNG</button><button class="btn secondary" id="jpgBtn">Convert to JPG</button></div><div id="out" class="output"></div>');
 }else if(name=="JSON Formatter"){
  h=shell(name,t[2],field("JSON","a","textarea",'placeholder="Paste JSON here..."')+'<button class="btn" id="run">Format JSON</button><div id="out" class="output"></div>');
 }else if(name=="JSON -> CSV"){
  h=shell(name,t[2],field("JSON array","a","textarea",'placeholder="[{&quot;name&quot;:&quot;Redro&quot;}]')+'<button class="btn" id="run">Convert to CSV</button><div id="out" class="output"></div>');
 }else if(name=="Base64 Encoder"){
  h=shell(name,t[2],field("Text","a","textarea")+'<div class="row"><button class="btn" id="enc">Encode</button><button class="btn secondary" id="dec">Decode</button></div><div id="out" class="output"></div>');
 }else if(name=="URL Encoder"){
  h=shell(name,t[2],field("Text","a","textarea")+'<div class="row"><button class="btn" id="enc">Encode</button><button class="btn secondary" id="dec">Decode</button></div><div id="out" class="output"></div>');
 }else if(name=="UUID Generator"){
  h=shell(name,t[2],'<button class="btn" id="run">Generate UUID</button><div id="out" class="output"></div>');
 }else if(name=="QR Generator"){
  h=shell(name,t[2],field("Text or URL","a")+'<button class="btn" id="run">Generate QR</button><div id="out" class="output"></div>');
 }else if(name=="Color Picker"){
  h=shell(name,t[2],'<div class="field"><input id="a" type="color" value="#e11d48"></div><div id="out" class="output"></div>');
 }else if(name=="Color Converter"){
  h=shell(name,t[2],field("HEX","a","input",'value="#e11d48"')+'<button class="btn" id="run">Convert</button><div id="out" class="output"></div>');
 }else if(name=="Timestamp Converter"){
  h=shell(name,t[2],field("Timestamp or date","a")+'<button class="btn" id="run">Convert</button><div id="out" class="output"></div>');
 }else if(name=="Regex Tester"){
  h=shell(name,t[2],field("Regex","a")+field("Test text","b","textarea")+'<button class="btn" id="run">Test</button><div id="out" class="output"></div>');
 }else if(name=="Markdown Preview"){
  h=shell(name,t[2],field("Markdown","a","textarea")+'<button class="btn" id="run">Preview</button><div id="out" class="output"></div>');
 }else if(name=="Text Diff"){
  h=shell(name,t[2],field("Text A","a","textarea")+field("Text B","b","textarea")+'<button class="btn" id="run">Compare</button><div id="out" class="output"></div>');
 }else if(name=="Word Counter"){
  h=shell(name,t[2],field("Text","a","textarea")+'<button class="btn" id="run">Count</button><div id="out" class="output"></div>');
 }else if(name=="Image Compressor"){
  h=shell(name,t[2],'<div class="field"><label>Image</label><input id="a" type="file" accept="image/*"></div><div class="field"><label>Quality</label><input id="q" type="range" min="0.1" max="1" step="0.1" value="0.7"></div><button class="btn" id="run">Compress & Download</button><div id="out" class="output"></div>');
 }else if(name=="Password Generator"){
  h=shell(name,t[2],'<div class="field"><label>Length</label><input id="a" type="number" min="4" max="128" value="20"></div><button class="btn" id="run">Generate</button><div id="out" class="output"></div>');
 }else if(name=="Hash Generator"){
  h=shell(name,t[2],field("Text","a","textarea")+'<button class="btn" id="run">SHA-256</button><div id="out" class="output"></div>');
 }else if(name=="JWT Decoder"){
  h=shell(name,t[2],field("JWT","a","textarea")+'<button class="btn" id="run">Decode</button><div id="out" class="output"></div>');
 }else if(name=="IP/Subnet Calculator"){
  h=shell(name,t[2],field("IPv4/CIDR","a")+'<button class="btn" id="run">Calculate</button><div id="out" class="output"></div>');
 }else if(name=="Cron Expression Helper"){
  h=shell(name,t[2],field("Cron","a")+'<button class="btn" id="run">Explain</button><div id="out" class="output"></div>');
 }
 view.innerHTML=h;modal.className="modal open";wireTool(name);
}
function wireTool(name){
 var a=$("#a"),run=$("#run");
 if(name=="JPG <-> PNG"){
  $("#pngBtn").onclick=function(){convertImage("image/png","redro-converted.png");};
  $("#jpgBtn").onclick=function(){convertImage("image/jpeg","redro-converted.jpg");};
 }else if(name=="JPG / PNG -> PDF"){
  $("#pdfBtn").onclick=function(){pdfPrint();};
 }else if(name=="JSON Formatter")run.onclick=function(){try{out(JSON.stringify(JSON.parse(a.value),null,2));}catch(e){out("Invalid JSON: "+e.message);}};
 else if(name=="JSON -> CSV")run.onclick=jsonCsv;
 else if(name=="Base64 Encoder"){$("#enc").onclick=function(){try{out(btoa(unescape(encodeURIComponent(a.value)));}catch(e){out("Encoding failed");}};$("#dec").onclick=function(){try{out(decodeURIComponent(escape(atob(a.value))));}catch(e){out("Invalid Base64");}};}
 else if(name=="URL Encoder"){$("#enc").onclick=function(){out(encodeURIComponent(a.value));};$("#dec").onclick=function(){try{out(decodeURIComponent(a.value));}catch(e){out("Invalid URL encoding");}};}
 else if(name=="UUID Generator")run.onclick=function(){out(makeUuid());};
 else if(name=="QR Generator")run.onclick=function(){var v=encodeURIComponent(a.value);$("#out").innerHTML='<img alt="QR code" width="260" height="260" src="https://api.qrserver.com/v1/create-qr-code/?size=260x260&data='+v+'">';};
 else if(name=="Color Picker")a.oninput=function(){out(a.value);};
 else if(name=="Color Converter")run.onclick=function(){var h=a.value.replace("#","");if(h.length==3)h=h.charAt(0)+h.charAt(0)+h.charAt(1)+h.charAt(1)+h.charAt(2)+h.charAt(2);var r=parseInt(h.substr(0,2),16),g=parseInt(h.substr(2,2),16),b=parseInt(h.substr(4,2),16);out("HEX: #"+h.toUpperCase()+"\nRGB: rgb("+r+", "+g+", "+b+")");};
 else if(name=="Timestamp Converter")run.onclick=function(){var v=a.value.trim(),d=/^\d{10,13}$/.test(v)?new Date((v.length==10?Number(v)*1000:Number(v))):new Date(v);out(isNaN(d.getTime())?"Invalid date":"ISO: "+d.toISOString()+"\nUnix: "+Math.floor(d.getTime()/1000));};
 else if(name=="Regex Tester")run.onclick=function(){try{var r=new RegExp(a.value,"g"),m=$("#b").value.match(r)||[];out("Matches: "+m.length+"\n"+m.join("\n"));}catch(e){out("Invalid regex: "+e.message);}};
 else if(name=="Markdown Preview")run.onclick=function(){var s=esc(a.value);s=s.replace(/^### (.*)$/gm,"<h3>$1</h3>").replace(/^## (.*)$/gm,"<h2>$1</h2>").replace(/^# (.*)$/gm,"<h1>$1</h1>").replace(/\*\*(.*?)\*\*/g,"<strong>$1</strong>").replace(/\n/g,"<br>");$("#out").innerHTML=s;};
 else if(name=="Text Diff")run.onclick=function(){var x=a.value.split("\n"),y=$("#b").value.split("\n"),n=Math.max(x.length,y.length),s="";for(var j=0;j<n;j++){if(x[j]===y[j])s+="  "+esc(x[j]||"")+"\n";else s+='<span class="diff-del">'+esc("- "+(x[j]||""))+'</span><br><span class="diff-add">'+esc("+ "+(y[j]||""))+"</span><br>";}$("#out").innerHTML=s;};
 else if(name=="Word Counter")run.onclick=function(){var s=a.value;out("Words: "+((s.trim().match(/\S+/g)||[]).length)+"\nCharacters: "+s.length+"\nCharacters without spaces: "+s.replace(/\s/g,"").length);};
 else if(name=="Image Compressor")run.onclick=compress;
 else if(name=="Password Generator")run.onclick=function(){var n=Math.max(4,Math.min(128,parseInt(a.value,10)||20)),chars="ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%^&*",s="",x=new Uint32Array(n);if(window.crypto&&crypto.getRandomValues)crypto.getRandomValues(x);for(var j=0;j<n;j++)s+=chars.charAt(x[j]%chars.length);out(s);};
 else if(name=="Hash Generator")run.onclick=hashText;
 else if(name=="JWT Decoder")run.onclick=function(){try{var p=a.value.split("."),dec=function(v){return JSON.parse(atob(v.replace(/-/g,"+").replace(/_/g,"/")));};out("HEADER\n"+JSON.stringify(dec(p[0]),null,2)+"\n\nPAYLOAD\n"+JSON.stringify(dec(p[1]),null,2));}catch(e){out("Invalid JWT");}};
 else if(name=="IP/Subnet Calculator")run.onclick=ipcalc;
 else if(name=="Cron Expression Helper")run.onclick=function(){var p=a.value.trim().split(/\s+/);out(p.length==5?"Minute: "+p[0]+"\nHour: "+p[1]+"\nDay: "+p[2]+"\nMonth: "+p[3]+"\nWeekday: "+p[4]:"Use 5 fields: minute hour day-of-month month day-of-week");};
}
function jsonCsv(){
 try{
  var a=JSON.parse($("#a").value);if(!a.length||Object.prototype.toString.call(a)!="[object Array]")throw Error("Expected a non-empty array");
  var keys=[],j,k,x;
  for(j=0;j<a.length;j++)for(k in a[j])if(keys.indexOf(k)<0)keys.push(k);
  var lines=[keys.join(",")];
  for(j=0;j<a.length;j++){x=[];for(k=0;k<keys.length;k++){var v=a[j][keys[k]];x.push('"'+String(v==null?"":v).replace(/"/g,'""')+'"');}lines.push(x.join(","));}
  out(lines.join("\n"));
 }catch(e){out("Invalid input: "+e.message);}
}
function makeUuid(){var d=new Date().getTime(),r="xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx";return r.replace(/[xy]/g,function(c){var q=(d+Math.random()*16)%16|0;d=Math.floor(d/16);return(c=="x"?q:(q&3|8)).toString(16);});}
function loadImage(file,cb){
 var reader=new FileReader();reader.onload=function(){var im=new Image();im.onload=function(){cb(null,im);};im.onerror=function(){cb(Error("Cannot read image"));};im.src=reader.result;};reader.onerror=function(){cb(Error("Cannot read file"));};reader.readAsDataURL(file);
}
function convertImage(type,name){
 var f=$("#a").files[0];if(!f)return out("Choose an image");
 loadImage(f,function(err,im){if(err)return out(err.message);var c=document.createElement("canvas");c.width=im.width;c.height=im.height;c.getContext("2d").drawImage(im,0,0);c.toBlob(function(b){downloadBlob(b,name);out("Done - downloaded "+name);},type,0.92);});
}
function pdfPrint(){
 var files=$("#a").files;if(!files.length)return out("Choose one or more images");
 var w=window.open("","_blank");if(!w)return out("Allow pop-ups to create the PDF");
 w.document.write("<title>Redro Tools - Print to PDF</title><style>body{font-family:sans-serif;text-align:center}img{max-width:95%;max-height:95vh;display:block;margin:20px auto;page-break-after:always}</style>");
 var left=files.length;
 for(var j=0;j<files.length;j++)(function(file){var r=new FileReader();r.onload=function(){w.document.write('<img src="'+r.result+'">');left--;if(!left){w.document.write("<script>setTimeout(function(){window.print();},500)<\\/script>");w.document.close();}};r.readAsDataURL(file);})(files[j]);
}
function compress(){
 var f=$("#a").files[0];if(!f)return out("Choose an image");
 var q=parseFloat($("#q").value),r=new FileReader();r.onload=function(){var im=new Image();im.onload=function(){var c=document.createElement("canvas"),max=1800,scale=Math.min(1,max/Math.max(im.width,im.height));c.width=Math.round(im.width*scale);c.height=Math.round(im.height*scale);c.getContext("2d").drawImage(im,0,0,c.width,c.height);c.toBlob(function(b){downloadBlob(b,"redro-compressed.jpg");out("Original: "+Math.round(f.size/1024)+" KB\nCompressed: "+Math.round(b.size/1024)+" KB");},"image/jpeg",q);};im.src=r.result;};r.readAsDataURL(f);
}
function hashText(){
 if(!window.crypto||!crypto.subtle)return out("SHA-256 is not supported in this browser");
 crypto.subtle.digest("SHA-256",new TextEncoder().encode($("#a").value)).then(function(buf){var a=new Uint8Array(buf),s="";for(var j=0;j<a.length;j++)s+=("0"+a[j].toString(16)).slice(-2);out(s);});
}
function ipcalc(){
 try{var z=$("#a").value.trim().split("/"),o=z[0].split("."),bits=parseInt(z[1],10);if(o.length!=4||isNaN(bits)||bits<0||bits>32)throw Error("Invalid IPv4/CIDR");var v=0,j;for(j=0;j<4;j++)v=(v*256)+(parseInt(o[j],10)||0);var mask=bits==0?0:(0xffffffff<<(32-bits))>>>0,net=(v&mask)>>>0,bc=(net|(~mask))>>>0;function fmt(x){return ((x>>>24)&255)+"."+((x>>>16)&255)+"."+((x>>>8)&255)+"."+(x&255);}out("Network: "+fmt(net)+"\nBroadcast: "+fmt(bc)+"\nMask: "+fmt(mask)+"\nAddresses: "+Math.pow(2,32-bits));}catch(e){out(e.message);}
}
function closeModal(){modal.className="modal";}
$("#close").onclick=closeModal;
modal.onclick=function(e){if(e.target===modal)closeModal();};
grid.onclick=function(e){var n=e.target;while(n&&n!==grid&&!n.getAttribute("data-i"))n=n.parentNode;if(n&&n!==grid)openTool(parseInt(n.getAttribute("data-i"),10));};
$("#themeBtn").onclick=function(){document.body.className=document.body.className.indexOf("dark")>=0?document.body.className.replace(" dark",""):document.body.className+" dark";try{localStorage.theme=document.body.className.indexOf("dark")>=0?"dark":"light";}catch(e){}};
try{if(localStorage.theme=="dark")document.body.className+=" dark";}catch(e){}
render();
})();