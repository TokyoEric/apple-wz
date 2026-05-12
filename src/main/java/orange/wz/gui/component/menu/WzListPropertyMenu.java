package orange.wz.gui.component.menu;

import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import orange.wz.gui.MainFrame;
import orange.wz.gui.component.panel.EditPane;

import javax.swing.*;

import static orange.wz.gui.Icons.*;

@Slf4j
public final class WzListPropertyMenu extends JPopupMenu {
    @Getter
    private final JMenuItem deleteBtn;
    @Getter
    private final JMenuItem copyBtn;
    @Getter
    private final JMenuItem pasteBtn;

    public WzListPropertyMenu(EditPane editPane) {
        super();

        JMenu addBtn = new JMenu("子节点");
        addBtn.setIcon(AiOutlinePlus);
        JMenuItem addCanvasBtn = new JMenuItem("图片");
        JMenuItem addConvexBtn = new JMenuItem("Convex");
        JMenuItem addDoubleBtn = new JMenuItem("Double");
        JMenuItem addFloatBtn = new JMenuItem("Float");
        JMenuItem addIntBtn = new JMenuItem("Int");
        JMenuItem addListBtn = new JMenuItem("列表");
        JMenuItem addLongBtn = new JMenuItem("Long");
        JMenuItem addNullBtn = new JMenuItem("Null");
        JMenuItem addShortBtn = new JMenuItem("Short");
        JMenuItem addSoundBtn = new JMenuItem("音频");
        JMenuItem addStringBtn = new JMenuItem("字符串");
        JMenuItem addUOLBtn = new JMenuItem("链接");
        JMenuItem addVectorBtn = new JMenuItem("向量");
        addBtn.add(addCanvasBtn);
        addBtn.add(addConvexBtn);
        addBtn.add(addDoubleBtn);
        addBtn.add(addFloatBtn);
        addBtn.add(addIntBtn);
        addBtn.add(addListBtn);
        addBtn.add(addLongBtn);
        addBtn.add(addNullBtn);
        addBtn.add(addShortBtn);
        addBtn.add(addSoundBtn);
        addBtn.add(addStringBtn);
        addBtn.add(addUOLBtn);
        addBtn.add(addVectorBtn);

        copyBtn = new JMenuItem(MainFrame.i18n.get("copy"), AiOutlineCopy);
        pasteBtn = new JMenuItem("粘贴", MdOutlineContentPaste);
        deleteBtn = new JMenuItem("删除节点", AiOutlineDelete);
        JMenuItem chineseBtn = new JMenuItem("汉化");
        JMenuItem compareImgBtn = new JMenuItem("图片对比");
        JMenuItem imageFinderBtn = new JMenuItem("图片嗅探");
        JMenuItem outlinkBtn = new JMenuItem("Outlink");
        JMenuItem sicBtn = new JMenuItem("排序并改名");
        JMenuItem delChild = new JMenuItem("批量删除");
        JMenuItem changeCavFmt = new JMenuItem("图片格式");
        JMenuItem scaleImage = new JMenuItem("图片缩放");
        JMenuItem changeNodeName = new JMenuItem("修改节点名");
        JMenuItem changeIntNodeValue = new JMenuItem("修改int值");
        JMenuItem rawToIcon = new JMenuItem("RawToIcon");
        JMenuItem changeOriginValue = new JMenuItem("修改图片origin");

        addCanvasBtn.addActionListener(e -> editPane.addCanvas());
        addConvexBtn.addActionListener(e -> editPane.addConvex());
        addDoubleBtn.addActionListener(e -> editPane.addDouble());
        addFloatBtn.addActionListener(e -> editPane.addFloat());
        addIntBtn.addActionListener(e -> editPane.addInt());
        addListBtn.addActionListener(e -> editPane.addList());
        addLongBtn.addActionListener(e -> editPane.addLong());
        addNullBtn.addActionListener(e -> editPane.addNull());
        addShortBtn.addActionListener(e -> editPane.addShort());
        addSoundBtn.addActionListener(e -> editPane.addSound());
        addStringBtn.addActionListener(e -> editPane.addString());
        addUOLBtn.addActionListener(e -> editPane.addUOL());
        addVectorBtn.addActionListener(e -> editPane.addVector());
        copyBtn.addActionListener(e -> editPane.doCopy());
        pasteBtn.addActionListener(e -> editPane.doPaste());
        deleteBtn.addActionListener(e -> editPane.delete());
        chineseBtn.addActionListener(e -> editPane.localizeString());
        compareImgBtn.addActionListener(e -> editPane.compareImg());
        imageFinderBtn.addActionListener(e -> editPane.imageFinder());
        outlinkBtn.addActionListener(e -> editPane.outlink());
        sicBtn.addActionListener(e -> editPane.sortAndReindexChildren());
        delChild.addActionListener(e -> editPane.removeAllWzChildWithName());
        changeCavFmt.addActionListener(e -> editPane.changeCavFmt());
        scaleImage.addActionListener(e -> editPane.scaleImage());
        changeNodeName.addActionListener(e -> editPane.changeNodeName());
        changeIntNodeValue.addActionListener(e -> editPane.changeIntNodeValue());
        rawToIcon.addActionListener(e -> editPane.rawToIcon());
        changeOriginValue.addActionListener(e -> editPane.changeOriginValue());

        add(addBtn);
        add(copyBtn);
        add(pasteBtn);
        add(deleteBtn);
        add(chineseBtn);
        add(compareImgBtn);
        add(imageFinderBtn);
        add(outlinkBtn);
        add(sicBtn);
        add(delChild);
        add(changeCavFmt);
        add(scaleImage);
        add(changeNodeName);
        add(changeIntNodeValue);
        add(rawToIcon);
        add(changeOriginValue);
    }
}
