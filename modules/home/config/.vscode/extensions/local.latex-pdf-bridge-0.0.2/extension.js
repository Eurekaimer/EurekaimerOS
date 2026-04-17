const fs = require('fs');
const path = require('path');
const vscode = require('vscode');

async function pathExists(filePath) {
  try {
    await fs.promises.access(filePath, fs.constants.F_OK);
    return true;
  } catch {
    return false;
  }
}

function getActiveTexDocument() {
  const editor = vscode.window.activeTextEditor;
  if (!editor) {
    vscode.window.showErrorMessage('No active editor.');
    return undefined;
  }

  const texUri = editor.document.uri;
  if (texUri.scheme !== 'file' || path.extname(texUri.fsPath).toLowerCase() !== '.tex') {
    vscode.window.showErrorMessage('Current file is not a local .tex file.');
    return undefined;
  }

  return texUri;
}

function resolveOutDir(texUri) {
  const cfg = vscode.workspace.getConfiguration('latex-workshop', texUri);
  const outDirRaw = cfg.get('latex.outDir');

  if (typeof outDirRaw !== 'string' || outDirRaw.trim() === '') {
    return path.dirname(texUri.fsPath);
  }

  const texDir = path.dirname(texUri.fsPath);
  const normalized = outDirRaw
    .replace(/%DIR%/g, texDir)
    .replace(/%DIR_W32%/g, texDir);

  if (path.isAbsolute(normalized)) {
    return normalized;
  }

  return path.resolve(texDir, normalized);
}

function resolvePdfPath(texUri) {
  const stem = path.basename(texUri.fsPath, path.extname(texUri.fsPath));
  const outDir = resolveOutDir(texUri);
  const primary = path.join(outDir, `${stem}.pdf`);
  const fallback = texUri.fsPath.replace(/\.tex$/i, '.pdf');
  return { primary, fallback };
}

async function openWithVscodePdf(pdfPath) {
  const pdfUri = vscode.Uri.file(pdfPath);

  try {
    await vscode.commands.executeCommand('vscode.openWith', pdfUri, 'pdf.preview');
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    vscode.window.showErrorMessage(`Failed to open PDF with vscode-pdf: ${message}`);
  }
}

async function openPdfForActiveTex() {
  const texUri = getActiveTexDocument();
  if (!texUri) {
    return;
  }

  const { primary, fallback } = resolvePdfPath(texUri);
  const target = (await pathExists(primary)) ? primary : fallback;

  if (!(await pathExists(target))) {
    vscode.window.showErrorMessage(`PDF not found: ${target}`);
    return;
  }

  await openWithVscodePdf(target);
}

function activate(context) {
  context.subscriptions.push(
    vscode.commands.registerCommand('latexPdfBridge.openPdfWithVscodePdf', openPdfForActiveTex)
  );
}

function deactivate() {}

module.exports = {
  activate,
  deactivate
};
