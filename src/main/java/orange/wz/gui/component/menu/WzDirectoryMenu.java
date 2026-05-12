package orange.wz.gui.component.menu;

import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import orange.wz.gui.MainFrame;
import orange.wz.gui.component.panel.EditPane;

import javax.swing.*;

import static orange.wz.gui.Icons.*;

@Slf4j
public final class WzDirectoryMenu extends JPopupMenu {
    @Getter
    private final JMenuItem deleteBtn;
    @Getter
    private final JMenuItem copyBtn;
    @Getter
    private final JMenuItem pasteBtn;

    public WzDirectoryMenu(EditPane editPane) {
        super();

        JMenu addBtn = new JMenu("子节点");
        addBtn.setIcon(AiOutlinePlus);
        JMenuItem addDirBtn = new JMenuItem("Directory");
        JMenuItem addImgBtn = new JMenuItem("Image");
        addBtn.add(addDirBtn);
        addBtn.add(addImgBtn);

        copyBtn = new JMenuItem(MainFrame.i18n.get("copy"), AiOutlineCopy);
        pasteBtn = new JMenuItem("粘贴", MdOutlineContentPaste);
        deleteBtn = new JMenuItem("删除节点", AiOutlineDelete);
        JMenuItem imageFinderBtn = new JMenuItem("图片嗅探");
        JMenuItem importBtn = new JMenu("导入");
        JMenuItem importImgBtn = new JMenuItem("Img");
        JMenuItem importXmlBtn = new JMenuItem("Xml");
        importBtn.add(importImgBtn);
        importBtn.add(importXmlBtn);
        JMenuItem compareImgBtn = new JMenuItem("图片对比");
        JMenuItem delNonCashEqpBtn = new JMenuItem("删除非时装");

        addDirBtn.addActionListener(e -> editPane.addWzDirectory());
        addImgBtn.addActionListener(e -> editPane.addWzImage());
        copyBtn.addActionListener(e -> editPane.doCopy());
        pasteBtn.addActionListener(e -> editPane.doPaste());
        deleteBtn.addActionListener(e -> editPane.delete());
        imageFinderBtn.addActionListener(e -> editPane.imageFinder());
        importImgBtn.addActionListener(e -> editPane.importImg());
        importXmlBtn.addActionListener(e -> editPane.importXml());
        compareImgBtn.addActionListener(e -> editPane.compareImg());
        delNonCashEqpBtn.addActionListener(e -> editPane.removeNonCashEqp());

        add(addBtn);
        add(copyBtn);
        add(pasteBtn);
        add(deleteBtn);
        add(imageFinderBtn);
        add(importBtn);
        add(compareImgBtn);
        add(delNonCashEqpBtn);
    }
}
