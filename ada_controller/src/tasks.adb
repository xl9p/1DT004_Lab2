with Ada.Text_IO;   use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with System;

with Webots_API; use Webots_API;

package body Tasks is
   -------------
   --  Tasks  --
   -------------
   type EventID is
     (UpPressed,
      DownPressed,
      LeftPressed,
      RightPressed,
      UpReleased,
      DownReleased,
      LeftReleased,
      RightReleased);

   protected Event is
      entry Wait (id : out EventID);
      procedure Signal (id : in EventID);
   private
      pragma Priority (System.Priority'Last);
      current_id : EventID;
      signalled  : Boolean := false;
      -- A fifo ring buffer for events, so we can queue them up?
   end Event;
   protected body Event is
      entry Wait (id : out EventID) when Signalled is
      begin
         id := current_id;
         signalled := false;
      end Wait;
      procedure Signal (id : in EventID) is
      begin
         current_id := id;
         signalled := true;
      end Signal;
   end Event;

   task EventDispatcherTask is
      pragma Priority (System.Priority'Last - 5);
   end EventDispatcherTask;
   task body EventDispatcherTask is
      Next_Release : Time := Clock;
      Period       : constant Time_Span := Milliseconds (10);
      UpState      : Boolean := False;
      DownState    : Boolean := False;
      LeftState    : Boolean := False;
      RightState   : Boolean := False;
   begin
      loop
         if button_pressed (UpButton) /= UpState then
            UpState := not UpState;
            if UpState then
               Event.Signal (UpPressed);
            else
               Event.Signal (UpReleased);
            end if;
         end if;

         if button_pressed (DownButton) /= DownState then
            DownState := not DownState;
            if DownState then
               Event.Signal (DownPressed);
            else
               Event.Signal (DownReleased);
            end if;
         end if;

         if button_pressed (LeftButton) /= LeftState then
            LeftState := not LeftState;
            if LeftState then
               Event.Signal (LeftPressed);
            else
               Event.Signal (LeftReleased);
            end if;
         end if;

         if button_pressed (RightButton) /= RightState then
            RightState := not RightState;
            if RightState then
               Event.Signal (RightPressed);
            else
               Event.Signal (RightReleased);
            end if;
         end if;

         Next_Release := Next_Release + Period;
         delay until Next_Release;

         exit when simulation_stopped;
      end loop;
   end EventDispatcherTask;

   task MotorControlTask is
      pragma Priority (System.Priority'Last - 4);
   end MotorControlTask;
   task body MotorControlTask is
      Next_Release    : Time := Clock;
      Period          : constant Time_Span := Milliseconds (1);
      EventTriggered  : EventID;
      LeftMotorSpeed  : MotorSpeed := 0;
      RightMotorSpeed : MotorSpeed := 0;
      -- Introduce Increment/Delta variable that is modified and then added to running motor speed;
   begin
      loop
         Event.Wait (EventTriggered);

         case EventTriggered is
            when UpPressed                 =>
               LeftMotorSpeed := 500;
               RightMotorSpeed := 500;

            when DownPressed               =>
               LeftMotorSpeed := -500;
               RightMotorSpeed := -500;

            when LeftPressed               =>
               LeftMotorSpeed := 0;
               RightMotorSpeed := 500;

            when RightPressed              =>
               LeftMotorSpeed := 500;
               RightMotorSpeed := 0;

            when UpReleased | DownReleased =>
               LeftMotorSpeed := 0;
               RightMotorSpeed := 0;

            when LeftReleased              =>
               RightMotorSpeed := 0;

            when RightReleased             =>
               LeftMotorSpeed := 0;
         end case;

         set_motor_speed (LeftMotor, LeftMotorSpeed);
         set_motor_speed (RightMotor, RightMotorSpeed);

         Next_Release := Next_Release + Period;
         delay until Next_Release;

         exit when simulation_stopped;
      end loop;
   end MotorControlTask;

   procedure Background is
   begin
      while not simulation_stopped loop
         delay 0.25;
      end loop;
   end Background;

end Tasks;
