-- Copyright (c) 2025 Matteo Grasso
-- 
--     https://github.com/matteogrs/templates.o3de.minimal.tactics
-- 
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
-- 
--     http://www.apache.org/licenses/LICENSE-2.0
-- 
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

local Health =
{
	Properties =
	{
		MaxValue = 3.0,
		Enemy = false,

		Events =
		{
			HealthRequestEvents = ScriptEventsAssetRef(),
			TurnNotificationEvents = ScriptEventsAssetRef()
		}
	}
}

function Health:OnActivate()
	self.value = self.Properties.MaxValue
	self.shield = false

	self.healthHandler = HealthRequestEvents.Connect(self, self.entityId)
	self.turnHandler = TurnNotificationEvents.Connect(self)
end

function Health:SetShield()
	self.shield = true
end

function Health:DecreaseHealth()
	local damage
	if self.shield then
		damage = 0.5
	else
		damage = 1.0
	end

	self.value = self.value - damage

	if self.value > 0.0 then
		local height = self.value / self.Properties.MaxValue
		local scale = Vector3(1.0, 1.0, height)

		NonUniformScaleRequestBus.Event.SetScale(self.entityId, scale)
	else
		GameEntityContextRequestBus.Broadcast.DestroyGameEntity(self.entityId)
	end
end

function Health:OnEnemyTurnStart()
	if self.Properties.Enemy then
		self.shield = false
	end
end

function Health:OnPlayerTurnStart()
	if not self.Properties.Enemy then
		self.shield = false
	end
end

function Health:OnDeactivate()
	self.turnHandler:Disconnect()
	self.healthHandler:Disconnect()
end

return Health
