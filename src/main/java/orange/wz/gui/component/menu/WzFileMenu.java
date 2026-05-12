package orange.wz.gui.component.menu;

import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import orange.wz.gui.MainFrame;
import orange.wz.gui.component.panel.EditPane;

import javax.swing.*;

import static orange.wz.gui.Icons.*;

@Slf4j
public final class WzFileMenu extends JPopupMenu {
    @Getter
    private final JMenuItem pasteBtn;

    public WzFileMenu(EditPane editPane) {
        super();

        JMenu addBtn = new JMenu("子节点");
        addBtn.setIcon(AiOutlinePlus);
        JMenuItem addDirBtn = new JMenuItem("Directory");
        JMenuItem addImgBtn = new JMenuItem("Image");
        addBtn.add(addDirBtn);
        addBtn.add(addImgBtn);
        JMenuItem saveBtn = new JMenuItem(MainFrame.i18n.get("save"), AiOutlineSaveIcon);
        JMenuItem saveAsBtn = new JMenuItem("另存为", AiOutlineSaveIcon);
        JMenuItem unloadBtn = new JMenuItem("卸载", AiOutlineCloseIcon);
        JMenuItem reloadBtn = new JMenuItem("重载", AiOutlineReloadIcon);
        JMenuItem moveBtn = new JMenuItem("转移视图", AiOutlineEye);
        pasteBtn = new JMenuItem("粘贴", MdOutlineContentPaste);
        JMenuItem keyBtn = new JMenuItem("修改密钥", AiOutlineKey);
        JMenu exportBtn = new JMenu("导出");
        JMenuItem exportImgBtn = new JMenuItem("Img");
        JMenuItem exportXmlBtn = new JMenuItem("Xml");
        exportBtn.add(exportImgBtn);
        exportBtn.add(exportXmlBtn);
        JMenuItem importBtn = new JMenu("导入");
        JMenuItem importImgBtn = new JMenuItem("Img");
        JMenuItem importXmlBtn = new JMenuItem("Xml");
        importBtn.add(importImgBtn);
        importBtn.add(importXmlBtn);
        JMenuItem chineseBtn = new JMenuItem("汉化");
        JMenuItem compareImgBtn = new JMenuItem("图片对比");
        JMenuItem outlinkBtn = new JMenuItem("Outlink");


        addDirBtn.addActionListener(e -> editPane.addWzDirectory());
        addImgBtn.addActionListener(e -> editPane.addWzImage());
        saveBtn.addActionListener(e -> editPane.save());
        saveAsBtn.addActionListener(e -> editPane.saveAs());
        unloadBtn.addActionListener(e -> editPane.unload());
        reloadBtn.addActionListener(e -> editPane.reloadFile());
        moveBtn.addActionListener(e -> editPane.move());
        pasteBtn.addActionListener(e -> editPane.doPaste());
        keyBtn.addActionListener(e -> editPane.changeKey());
        exportImgBtn.addActionListener(e -> editPane.exportImg());
        exportXmlBtn.addActionListener(e -> editPane.exportXml());
        importImgBtn.addActionListener(e -> editPane.importImg());
        importXmlBtn.addActionListener(e -> editPane.importXml());
        chineseBtn.addActionListener(e -> editPane.localizeString());
        compareImgBtn.addActionListener(e -> editPane.compareImg());
        outlinkBtn.addActionListener(e -> editPane.outlink());

        add(addBtn);
        add(saveBtn);
        add(saveAsBtn);
        add(unloadBtn);
        add(reloadBtn);
        add(moveBtn);
        add(pasteBtn);
        add(keyBtn);
        add(exportBtn);
        add(importBtn);
        add(chineseBtn);
        add(compareImgBtn);
        add(outlinkBtn);
    }
}
