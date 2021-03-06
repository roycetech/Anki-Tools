/**
 *   Copyright 2016 Royce Remulla
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package ph.rye.anki.view;

import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;

import javax.swing.JFileChooser;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.filechooser.FileFilter;

import ph.rye.anki.AnkiAppException;
import ph.rye.anki.AnkiMainGui;
import ph.rye.anki.model.AnkiService;

/**
 * @author royce
 *
 */
public class MenuBar extends JMenuBar {


    /** */
    private static final long serialVersionUID = -2667573788830181344L;


    private static final String SEP_TITLE = " - ";


    private final transient AnkiService service;


    private final transient AnkiMainGui parent;

    private transient JFileChooser fileChooser;


    private final transient JMenu mnuFile = new JMenu();
    private final transient JMenuItem mnuOpen = new JMenuItem();
    private final transient JMenuItem mnuSaveAs = new JMenuItem();
    private final transient JMenuItem mnuSave = new JMenuItem();
    private final transient JMenuItem mnuExport = new JMenuItem();
    private final transient JMenuItem mnuExit = new JMenuItem();

    private transient File openFile;


    public MenuBar(final AnkiMainGui parent, final AnkiService service) {
        this.parent = parent;
        this.service = service;
    }

    @SuppressWarnings("PMD.DoNotCallSystemExit")
    public void initComponents() {
        mnuFile.setText("File");

        mnuOpen.setAccelerator(
            javax.swing.KeyStroke
                .getKeyStroke(KeyEvent.VK_O, InputEvent.META_MASK));

        mnuOpen.setText("Open...");
        mnuOpen.addActionListener(evt -> mnuOpenActionPerformed());
        mnuFile.add(mnuOpen);

        mnuSave.setAccelerator(
            javax.swing.KeyStroke
                .getKeyStroke(KeyEvent.VK_S, InputEvent.META_MASK));

        mnuSave.setText("Save");
        mnuSave.setEnabled(false);
        mnuSave.addActionListener(event -> mnuSavePerformed());
        mnuFile.add(mnuSave);

        mnuSaveAs.setText("Save As...");
        mnuSaveAs.setEnabled(false);
        mnuFile.add(mnuSaveAs);

        mnuExport.setAccelerator(
            javax.swing.KeyStroke
                .getKeyStroke(KeyEvent.VK_E, InputEvent.META_MASK));
        mnuExport.setText("Export");
        mnuExport.setEnabled(false);
        mnuExport.addActionListener(evt -> mnuExportClicked());
        mnuFile.add(mnuExport);

        mnuExit.setAccelerator(
            javax.swing.KeyStroke
                .getKeyStroke(KeyEvent.VK_Q, InputEvent.META_MASK));
        mnuExit.setText("Quit");
        mnuExit.addActionListener(event -> System.exit(0));
        mnuFile.add(mnuExit);

        add(mnuFile);
    }

    private void mnuExportClicked() {
        final JFileChooser fileChooser = new JFileChooser();
        fileChooser.setDialogType(JFileChooser.CUSTOM_DIALOG);
        fileChooser.setCurrentDirectory(
            new File("/Users/royce/Desktop/Anki Generated Sources"));
        fileChooser.setSelectedFile(new File(openFile.getName()));
        fileChooser.setApproveButtonToolTipText("Export");
        final int rVal = fileChooser.showDialog(parent, "Export");
        if (rVal == JFileChooser.APPROVE_OPTION) {
            service.exportSelected(fileChooser.getSelectedFile());
            JOptionPane.showMessageDialog(parent, "Export completed!");
        }

    }

    private void mnuSavePerformed() {
        parent.setFileClean();
        try {
            service.saveToFile(null);
        } catch (final IOException e) {
            JOptionPane.showMessageDialog(
                parent,
                "Could not save file!",
                "Save Error",
                JOptionPane.ERROR_MESSAGE);
        }
        mnuSave.setEnabled(false);
    }

    private void mnuOpenActionPerformed() {
        if (fileChooser == null) {
            fileChooser = new JFileChooser();
            fileChooser.setCurrentDirectory(
                new File("/Users/royce/DropBox/Documents/Reviewer/"));
            fileChooser.setFileFilter(new FileFilter() {
                @Override
                public boolean accept(final File pathname) {
                    return pathname.getName().endsWith(".txt")
                            && pathname.isFile() || pathname.isDirectory();
                }

                @Override
                public String getDescription() {
                    return "Text Files";
                }
            });
        }

        final int returnVal = fileChooser.showOpenDialog(this);
        if (returnVal == JFileChooser.APPROVE_OPTION) {
            final File file = fileChooser.getSelectedFile();
            selectFile(file);
        }

    }

    public void selectFile(final File file) {
        openFile = file;

        String appTitle;
        final int sepIndex = parent.getTitle().indexOf(SEP_TITLE);
        if (sepIndex > -1) {
            appTitle = parent.getTitle().substring(0, sepIndex);
        } else {
            appTitle = parent.getTitle();
        }

        parent.setTitle(appTitle + SEP_TITLE + file.getName());
        try {
            service.openFile(file);
        } catch (final FileNotFoundException e) {
            throw new AnkiAppException(e);
        }

        mnuSaveAs.setEnabled(true);
        mnuExport.setEnabled(true);
        parent.getPanelLeft().setApplyButtonEnabled(false);
        parent.getPanelLeft().getTextArea().setEditable(false);
        parent.getPanelLeft().getTextArea().setText("");
        parent.getPanelBottom().refreshLabelText();
        parent.getPanelBottom().selectFirstRow();
    }

    /**
     *
     */
    void enableSave() {
        mnuSave.setEnabled(true);
    }


}
