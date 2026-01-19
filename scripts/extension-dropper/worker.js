const TARGET = "http://127.0.0.1:8765/dropper";

async function postDrop(tab) {
  try {
    const [{ result }] = await chrome.scripting.executeScript({
      target: { tabId: tab.id },
      func: () => ({
        title: document.title || "",
        url: location.href || "",
        selection: window.getSelection()?.toString() || "",
        html: document.getSelection ? document.getSelection().toString() : "",
      }),
    });
    const payload = {
      title: result.title,
      url: result.url,
      selection: result.selection,
      html: result.html,
      app: "browser-extension",
    };
    await fetch(TARGET, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });
  } catch (e) {
    console.error("mfm dropper error", e);
  }
}

chrome.action.onClicked.addListener((tab) => {
  postDrop(tab);
});

chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: "mfm-drop",
    title: "Send to my--father-mother",
    contexts: ["selection", "page"],
  });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === "mfm-drop" && tab?.id !== undefined) {
    postDrop(tab);
  }
});
