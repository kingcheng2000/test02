
////////////////////////////////////////////////////
//
//    W_template.pde (ie "Widget Template")
//
//    This is a Template Widget, intended to be used as a starting point for OpenBCI Community members that want to develop their own custom widgets!
//    Good luck! If you embark on this journey, please let us know. Your contributions are valuable to everyone!
//
//    Created by: Conor Russomanno, November 2016
//
///////////////////////////////////////////////////,


class W_GanglionImpedance extends Widget {
    Button startStopCheck;
    int padding = 24;

    W_GanglionImpedance(PApplet _parent){
        super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

        createStartStopCheck("startStopCheck", "Start Impedance Check", x + padding, y + padding, 200, navHeight, p4, 14, colorNotPressed, OPENBCI_DARKBLUE);
    }

    void update(){
        super.update(); //calls the parent update() method of Widget (DON'T REMOVE)
    }

    void draw(){
        super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

        //remember to refer to x,y,w,h which are the positioning variables of the Widget class
        pushStyle();

        //divide by 2 ... we do this assuming that the D_G (driven ground) electrode is "comprable in impedance" to the electrode being used.
        fill(OPENBCI_DARKBLUE);
        textFont(p4, 14);

        BoardGanglion ganglion = (BoardGanglion)currentBoard;
        if (!ganglion.isCheckingImpedance()) {
            return;
        }

        int resistanceChannels[] = ganglion.getResistanceChannels();
        List<double[]> data = ganglion.getData(1);

        // todo format in brainflow, 4 channels and reference. Does it match this code
        for(int i = 0; i < resistanceChannels.length; i++){
            String toPrint;
            float adjustedImpedance = (float)data.get(0)[resistanceChannels[i]]/2.0;
            if(i == (resistanceChannels.length - 1)) {
                toPrint = "Reference Impedance \u2248 " + adjustedImpedance + " k\u2126";
            } else {
                toPrint = "Channel[" + i + "] Impedance \u2248 " + adjustedImpedance + " k\u2126";
            }
            text(toPrint, x + padding + 40, y + padding*2 + 12 + startStopCheck.getHeight() + padding*(i));

            pushStyle();
            stroke(OPENBCI_DARKBLUE);
            //change the fill color based on the signal quality...
            if(adjustedImpedance <= 0){ //no data yet...
                fill(255);
            } else if(adjustedImpedance > 0 && adjustedImpedance <= 10){ //very good signal quality
                fill(49, 113, 89); //dark green
            } else if(adjustedImpedance > 10 && adjustedImpedance <= 50){ //good signal quality
                fill(184, 220, 105); //yellow green
            } else if(adjustedImpedance > 50 && adjustedImpedance <= 100){ //acceptable signal quality
                fill(221, 178, 13); //yellow
            } else if(adjustedImpedance > 100 && adjustedImpedance <= 150){ //questionable signal quality
                fill(253, 94, 52); //orange
            } else if(adjustedImpedance > 150){ //bad signal quality
                fill(224, 56, 45); //red
            }

            ellipse(x + padding + 10, y + padding*2 + 7 + startStopCheck.getHeight() + padding*(i), padding/2, padding/2);
            popStyle();
        }

        image(loadingGIF_blue, x + padding + startStopCheck.getWidth() + 15, y + padding - 8, 40, 40);
        popStyle();
    }

    void screenResized(){
        super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)
        startStopCheck.setPosition(x + padding, y + padding);
    }

    void mousePressed(){
        super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
    }

    void mouseReleased(){
        super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)
    }

    private void createStartStopCheck(String name, String text, int _x, int _y, int _w, int _h, PFont _font, int _fontSize, color _bg, color _textColor) {
        startStopCheck = createButton(cp5_widget, name, text, _x, _y, _w, _h, _font, _fontSize, _bg, _textColor);
        startStopCheck.onRelease(new CallbackListener() {
            public void controlEvent(CallbackEvent theEvent) {
                if (currentBoard instanceof BoardGanglion) {
                    // ganglion is the only board which can check impedance, so we don't have an interface for it.
                    // if that changes in the future, consider making an interface.
                    BoardGanglion ganglionBoard = (BoardGanglion)currentBoard;
                    if (!ganglionBoard.isCheckingImpedance()) {
                        // We need to either stop the time series data, or allow it to scroll, like currently. 
                        // the values in time series are not meaningful when Impedance check is active
                        println("Starting Ganglion impedance check...");
                        //Start impedance check
                        ganglionBoard.setCheckingImpedance(true);
                        startStopCheck.getCaptionLabel().setText("Stop Impedance Check");
                    } else {
                        //Stop impedance check
                        ganglionBoard.setCheckingImpedance(false);
                        startStopCheck.getCaptionLabel().setText("Start Impedance Check");
                    }
                }
            }
        });
        startStopCheck.setDescription("Click this button to start or stop checking impedance.");
    }
};
